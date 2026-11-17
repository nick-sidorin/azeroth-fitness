local _, AF = ...
local Jump = {}
AF.Jump = Jump

-- A hook observes the user's own jump button; it never initiates movement.
-- A press only becomes a jump when followed by an airborne transition.
-- This intentionally misses unusual input bindings and some short hops.
local pendingAt = nil
local lastCount = -10
local function safe(value)
  return value ~= nil and not (issecretvalue and issecretvalue(value))
end
local function disallowed()
  if UnitOnTaxi("player") or UnitIsGhost("player") then return true end
  if UnitInVehicle and UnitInVehicle("player") then return true end
  if IsSwimming and safe(IsSwimming()) and IsSwimming() then return true end
  if IsMounted and safe(IsMounted()) and IsMounted() then return true end
  if IsFlying and safe(IsFlying()) and IsFlying() then return true end
  return false
end

local watcher = CreateFrame("Frame")
watcher:Hide()
watcher:SetScript("OnUpdate", function()
  if not pendingAt then watcher:Hide(); return end
  local now = GetTime()
  if now - pendingAt > 0.8 or disallowed() then
    pendingAt = nil
    watcher:Hide()
    return
  end
  local falling = IsFalling and IsFalling()
  if safe(falling) and falling then
    pendingAt = nil
    watcher:Hide()
    if now - lastCount >= 0.35 then
      lastCount = now
      AF:RecordJump()
    end
  end
end)

function Jump.Reset()
  pendingAt, lastCount = nil, -10
  watcher:Hide()
end

function Jump.Start()
  if not JumpOrAscendStart or not hooksecurefunc then return end
  hooksecurefunc("JumpOrAscendStart", function()
    if disallowed() then return end
    local falling = IsFalling and IsFalling()
    if not safe(falling) or falling then return end
    pendingAt = GetTime()
    watcher:Show()
  end)
end
