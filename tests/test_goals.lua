local now = os.time({ year = 2026, month = 11, day = 10, hour = 12 })
date = function(format, timestamp) return os.date(format, timestamp or now) end
time = os.time
UnitGUID = function() return "Player-Goals" end
UnitName = function() return "Test" end
local AF = {}
assert(loadfile("Core.lua"))("AzerothFitness", AF)
AF:Init()
-- Simulate an existing schema-1 character with genuine historical activity.
local old = AF:NewLedger()
old.steps, old.goal = 2345, 8000
AzerothFitnessDB.characters["Player-Goals"] = { goal = 9000, days = { ["2026-11-09"] = old } }
AF:Login()
assert(AF:Today().goal == 9000 and AF.char.activityGoals.jumps == 100)
assert(old.steps == 2345 and old.goal == 8000 and old.activityGoals == nil)
local today = AF:Today()
for _, values in ipairs({ { 0, 100, 300 }, { 10000, 0, 300 }, { 10000, 100, math.huge },
    { 10000, 100, 0/0 }, { "invalid", 100, 300 } }) do
  local ok = AF:SetDailyGoals(unpack(values))
  assert(not ok and AF.char.goal == 9000 and today.activityGoals.jumps == 100)
end
assert(AF:SetDailyGoals(12000, 150, 400))
assert(today.goal == 12000 and today.activityGoals.jumps == 150 and today.activityGoals.murlos == 400)
now = os.time({ year = 2026, month = 11, day = 11, hour = 12 })
local tomorrow = AF:Today()
assert(tomorrow.activityGoals ~= today.activityGoals and tomorrow.activityGoals.jumps == 150)
assert(AF:SetDailyGoals(15000, 200, 500))
assert(today.goal == 12000 and today.activityGoals.jumps == 150)
AF:Login()
assert(AF:Today().activityGoals.jumps == 200 and old.activityGoals == nil)
AF.char.activityGoals = { jumps = "invalid", murlos = 650 }
AF:Today().activityGoals = { murlos = 500 }
AF:Login()
assert(AF.char.activityGoals.jumps == 100 and AF.char.activityGoals.murlos == 650)
assert(AF:Today().activityGoals.jumps == 100 and AF:Today().activityGoals.murlos == 500)
print("PASS: additive goal upgrade, atomic validation, reload, daily rollover and historical target preservation")
