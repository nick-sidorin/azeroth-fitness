local frames, records = {}, {}
CreateFrame = function()
  local frame = { shown = true, scripts = {} }
  function frame:Hide() self.shown = false end
  function frame:Show() self.shown = true end
  function frame:IsShown() return self.shown end
  function frame:SetScript(event, callback) self.scripts[event] = callback end
  function frame:RegisterEvent() end
  frames[#frames + 1] = frame
  return frame
end
local moving, coordinates, x, speed, mounted = false, true, 0, 7, false
IsPlayerMoving = function() return moving end
UnitOnTaxi = function() return false end
UnitIsGhost = function() return false end
IsMounted = function() return mounted end
UnitPosition = function() if coordinates then return x, 0, 0, 1 end end
GetUnitSpeed = function() return speed, 7 end
GetPlayerFacing = function() return 0 end
local AF = { RecordTravel = function(_, ...) records[#records + 1] = { ... } end }
assert(loadfile("Motion.lua"))("AzerothFitness", AF)
AF.Motion.Start()
local driver, events = frames[1], frames[2]
assert(not driver:IsShown(), "Sampler must sleep when idle")
moving = true
events.scripts.OnEvent(events, "PLAYER_STARTED_MOVING")
assert(driver:IsShown())
x = 1.4
driver.scripts.OnUpdate(driver, 0.2)
assert(#records == 1 and records[1][1] == "run" and records[1][4] == "position")

-- A huge position discontinuity is discarded and the next sample is rebased.
x = 1000
driver.scripts.OnUpdate(driver, 0.2)
assert(#records == 1)
x = 1001.4
driver.scripts.OnUpdate(driver, 0.2)
assert(#records == 2)

-- Without coordinates, speed supplies distance but cannot supply direction.
coordinates = false
driver.scripts.OnUpdate(driver, 0.2)
assert(#records == 3 and records[3][1] == "unknown" and records[3][4] == "speed")
assert(math.abs(records[3][2] - 1.4) < 0.000001)
speed = nil
driver.scripts.OnUpdate(driver, 0.2)
assert(#records == 3, "Missing position and speed must not fabricate travel")

coordinates, speed, x = true, 7, 2000
driver.scripts.OnUpdate(driver, 0.2)
x = 2001.4
mounted = true
driver.scripts.OnUpdate(driver, 0.2)
assert(#records == 4 and records[4][1] == "mount")
speed, x = 0, 2004
driver.scripts.OnUpdate(driver, 0.2)
assert(#records == 4, "Carrier displacement must not become player travel")
moving = false
events.scripts.OnEvent(events, "PLAYER_STOPPED_MOVING")
assert(not driver:IsShown())
print("PASS: idle sleep, position sampling, discontinuity filter, speed fallback, unknown direction and mount/carrier separation")

-- Reset rebases coordinates and discards the partially sampled interval.
moving, mounted, speed, x = true, false, 7, 3000
events.scripts.OnEvent(events, "PLAYER_STARTED_MOVING")
driver.scripts.OnUpdate(driver, 0.1)
x = 3001
AF.Motion.Reset()
local before = #records
x = 3001.7
driver.scripts.OnUpdate(driver, 0.1)
assert(#records == before, "Reset must discard pre-reset sampling time")
driver.scripts.OnUpdate(driver, 0.1)
assert(#records == before + 1 and math.abs(records[#records][2] - 0.7) < 0.000001,
  "Reset must discard pre-reset coordinate displacement")
