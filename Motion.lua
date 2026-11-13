local _, AF = ...

-- Movement samples are taken only when the character is moving, in a vehicle,
-- or during a short post-movement settling interval. We never poll per frame.
local Motion = {}
AF.Motion = Motion

local SAMPLE_PERIOD = 0.20
local MAX_INTERVAL = 0.8
local TELEPORT_YARDS_PER_SECOND = 65
local CARRIED_MARGIN = 2
local SIDE_COSINE = 0.50
local EPSILON = 0.01
local sqrt, sin, cos, abs, max = math.sqrt, math.sin, math.cos, math.abs, math.max

local function safe(value)
  return value ~= nil and not (issecretvalue and issecretvalue(value))
end

local function position()
  if not UnitPosition then return nil end
  local x, y, _, instance = UnitPosition("player")
  if not safe(x) or not safe(y) or not safe(instance) then return nil end
  return x, y, instance
end

local function speed()
  if not GetUnitSpeed then return nil end
  local current, run = GetUnitSpeed("player")
  if not safe(current) or not safe(run) then return nil end
  return current, run
end

local function facing()
  if not GetPlayerFacing then return nil end
  local angle = GetPlayerFacing()
  if safe(angle) then return angle end
end

local function flag(name)
  local fn = _G[name]
  if type(fn) ~= "function" then return false end
  local value = fn()
  if not safe(value) then return false end
  return value and true or false
end

local function mode()
  if UnitIsGhost("player") then return "ignore" end
  if UnitOnTaxi("player") then return "transport" end
  if UnitInVehicle and UnitInVehicle("player") then return "transport" end
  if flag("IsSwimming") then return "swim" end
  if flag("IsMounted") then return "mount" end
  if flag("IsFlying") or flag("IsFalling") then return "air" end
  if GetShapeshiftFormID then
    local form = GetShapeshiftFormID()
    -- Animal travel forms must not generate humanoid step counts.
    local travel = { [1] = true, [3] = true, [4] = true, [5] = true,
      [8] = true, [16] = true, [27] = true, [29] = true }
    if safe(form) and travel[form] then return "other" end
  end
  return "foot"
end

local driver = CreateFrame("Frame")
driver:Hide()
local previousX, previousY, previousMap
local pending = 0
local previousSpeed = 0
local lastRunSpeed = BASE_MOVEMENT_SPEED or 7
Motion.probe = { mode = "idle", source = "none", direction = "unknown", speed = 0 }

local function rebase()
  previousX, previousY, previousMap = position()
end

function Motion.Reset()
  pending, previousSpeed = 0, 0
  rebase()
end

-- UnitPosition axes and GetPlayerFacing use the same north/west convention.
local function classify(dx, dy, distance, angle)
  if not angle or distance <= EPSILON then return "unknown" end
  local forward = (dx * cos(angle) + dy * sin(angle)) / distance
  local left = (-dx * sin(angle) + dy * cos(angle)) / distance
  if forward < -SIDE_COSINE then return "back" end
  if abs(forward) <= SIDE_COSINE then
    return left > 0 and "strafeLeft" or "strafeRight"
  end
  return "forward"
end

local function interval(dt)
  local current, run = speed()
  if run and run > 0 then lastRunSpeed = run end
  local x, y, map = position()
  local distance, dx, dy, source = 0, nil, nil, "none"

  if x then
    if previousX and map == previousMap then
      dx, dy = x - previousX, y - previousY
      distance = sqrt(dx * dx + dy * dy)
      if distance / dt > TELEPORT_YARDS_PER_SECOND then
        distance, dx, dy = 0, nil, nil
      end
    end
    source = "position"
  elseif current then
    distance = current * dt
    source = "speed"
  end
  previousX, previousY, previousMap = x, y, map

  Motion.probe.source = source
  Motion.probe.speed = current or (dt > 0 and distance / dt or 0)

  -- Do not turn camera pans, idle vehicle movement, portals, or loading screens into steps.
  if distance < EPSILON then previousSpeed = current or 0; return end
  local travelMode = mode()
  Motion.probe.mode = travelMode
  local estimatedOwn = max(current or 0, previousSpeed or 0) * dt
  previousSpeed = current or 0

  -- A ship/zeppelin/tram can move the player without updating GetUnitSpeed.
  -- In ambiguous transport situations, *discard* activity rather than invent steps.
  if dx and current and distance > estimatedOwn + CARRIED_MARGIN * dt then
    Motion.probe.mode = "carried"
    return
  end
  if travelMode == "ignore" or travelMode == "air" or travelMode == "other" then return end

  if travelMode == "transport" then
    AF:RecordTravel("transport", distance, dt, source)
    return
  end
  if travelMode == "mount" or travelMode == "swim" then
    AF:RecordTravel(travelMode, distance, dt, source)
    return
  end

  local direction = dx and classify(dx, dy, distance, facing()) or "unknown"
  Motion.probe.direction = direction
  local gait
  if direction == "back" then
    gait = "back"
  elseif direction == "strafeLeft" or direction == "strafeRight" then
    gait = direction
  elseif direction == "unknown" then
    gait = "unknown"
  else
    gait = Motion.probe.speed < lastRunSpeed * 0.60 and "walk" or "run"
  end
  -- Strafing has a running/walking cadence; preserve sideways distance separately.
  local strideGait = gait
  if gait == "strafeLeft" or gait == "strafeRight" or gait == "unknown" then
    strideGait = Motion.probe.speed < lastRunSpeed * 0.60 and "walk" or "run"
  end
  AF:RecordTravel(gait, distance, dt, source, strideGait)
end

driver:SetScript("OnUpdate", function(_, elapsed)
  pending = pending + elapsed
  if pending < SAMPLE_PERIOD then return end
  if pending <= MAX_INTERVAL then interval(pending) else rebase() end
  pending = 0
  if AF.Jump and AF.Jump.Update then AF.Jump.Update() end
  if not IsPlayerMoving() and not UnitOnTaxi("player")
      and not (UnitInVehicle and UnitInVehicle("player")) then
    driver:Hide()
    Motion.probe.mode = "idle"
  end
end)

local function wake()
  if driver:IsShown() then return end
  previousSpeed = 0
  pending = 0
  rebase()
  driver:Show()
end

local function sleep()
  if not driver:IsShown() or IsPlayerMoving() or UnitOnTaxi("player") then return end
  if pending > 0 and pending < MAX_INTERVAL then interval(pending) end
  pending = 0
  driver:Hide()
  Motion.probe.mode = "idle"
end

function Motion.Start()
  local events = CreateFrame("Frame")
  events:RegisterEvent("PLAYER_STARTED_MOVING")
  events:RegisterEvent("PLAYER_STOPPED_MOVING")
  events:RegisterEvent("PLAYER_ENTERING_WORLD")
  events:RegisterEvent("PLAYER_CONTROL_GAINED")
  events:RegisterEvent("PLAYER_CONTROL_LOST")
  events:RegisterEvent("UNIT_ENTERED_VEHICLE")
  events:RegisterEvent("UNIT_EXITED_VEHICLE")
  events:SetScript("OnEvent", function(_, event, unit)
    if (event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE")
        and unit ~= "player" then return end
    if event == "PLAYER_ENTERING_WORLD" then
      driver:Hide()
      rebase()
    end
    if IsPlayerMoving() or UnitOnTaxi("player")
        or (UnitInVehicle and UnitInVehicle("player")) then
      wake()
    else
      sleep()
    end
  end)
  if IsPlayerMoving() then wake() end
end
