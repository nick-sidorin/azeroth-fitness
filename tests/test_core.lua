local now = os.time({ year = 2026, month = 11, day = 10, hour = 12 })
date = function(format, timestamp) return os.date(format, timestamp or now) end
time = os.time
local guid = "Player-1"
UnitGUID = function() return guid end
UnitName = function() return "Test" end
UnitRace = function() return "Human", "Human" end
GetLocale = function() return "enUS" end

local AF = {}
assert(loadfile("Locale.lua"))("AzerothFitness", AF)
assert(loadfile("Core.lua"))("AzerothFitness", AF)
local messages = {}
AF.Say = function(_, message) messages[#messages + 1] = message end
AF:Init()
AF:Login()
local function near(actual, expected)
  assert(math.abs(actual - expected) < 0.000001, tostring(actual) .. " != " .. expected)
end

assert(AF:DayKey() == "2026-11-10" and AF:DayKey(1) == "2026-11-09")
AF:RecordTravel("run", 23, 3, "position")
AF:RecordTravel("walk", 12.65, 4, "speed")
AF:RecordJump()
local day = AF:Today()
near(day.steps, 20)
near(AF.char.total.steps, 20)
near(day.murlos, 23 / 100 * 1.8 + 12.65 / 100 * 1.2 + 0.75)
assert(day.jumps == 1 and AF.char.total.jumps == 1)
assert(day.moveSeconds == 7 and day.coverage.position == 23 and day.coverage.speed == 12.65)

AF:RecordTravel("mount", 100, 10, "position")
AF:RecordTravel("transport", 50, 5, "position")
AF:RecordTravel("swim", 100, 20, "speed")
near(day.steps, 20)
near(AF:FootYards(day), 35.65)
near(day.murlos, AF.char.total.murlos)
assert(day.coverage.position == 23 and day.coverage.speed == 12.65)

-- Login reuses saved tables and does not replay activity into lifetime totals.
local saved, totalSteps = AzerothFitnessDB, AF.char.total.steps
AF:Init()
AF:Login()
assert(AzerothFitnessDB == saved and AF:Today() == day)
near(AF.char.total.steps, totalSteps)

-- New local dates get the current goal; previous dates keep their own targets.
AF.char.goal, day.goal = 100, 100
AF:RecordTravel("run", 230, 30, "position")
assert(AF:Streak() == 1)
now = os.time({ year = 2026, month = 11, day = 11, hour = 12 })
AF.char.goal = 200
local nextDay = AF:Today()
assert(nextDay ~= day and nextDay.goal == 200 and day.goal == 100)
assert(AF:Streak() == 1)
AF:RecordTravel("run", 460, 60, "position")
assert(AF:Streak() == 2)
near(AF:Aggregate(2).steps, AF.char.total.steps)
near(AF:Aggregate(2).jumps, AF.char.total.jumps)
local bestKey = AF:BestDay()
assert(bestKey == "2026-11-11")

guid = "Player-2"
AF:Login()
assert(AF.char.total.steps == 0 and AF:Today().jumps == 0)
guid = "Player-1"
AF:Login()
near(AF.char.total.steps, 320)
AF.db.language = "ru"
assert(AF:T("TODAY") ~= "TODAY")
AF.db.language = "en"
assert(AF:T("TODAY") == "Today")
print("PASS: daily/lifetime accounting, fictional calories, reload, goals, dates, streak and character isolation")
