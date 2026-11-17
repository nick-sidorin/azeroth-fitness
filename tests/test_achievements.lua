local Mock = assert(loadfile("tests/ui_mock.lua"))()
date, time = os.date, os.time
GetLocale = function() return "enUS" end
local guid = "Player-Achievements"
UnitGUID = function() return guid end
UnitName = function() return "Tester" end
UnitRace = function() return "Human", "Human" end
local AF = {}
for _, file in ipairs({ "Locale.lua", "LocaleTranslations.lua", "Core.lua", "Achievements.lua" }) do
  assert(loadfile(file))("AzerothFitness", AF)
end
AF.Say = function() end
AF:Init(); AF:Login()
local A = AF.Achievements
local page = CreateFrame("Frame", nil, UIParent)
page:Hide()
A:Build(page); A:Refresh()
assert(A.scrollbar.template == "MinimalScrollBar")
local points, possible = AF:GetAchievementPoints()
assert(points == 0 and possible == 80)
assert(A.rows[1].icon.desaturated and not A.toast)
AF:RecordTravel("run", 2.3 * 49, 15, "position")
assert(not AF.char.achievements.firstSteps)
AF:RecordTravel("run", 2.3, 1, "position")
assert(AF.char.achievements.firstSteps == AF:DayKey())
assert(AF:GetAchievementPoints() == 10 and A.current.id == "firstSteps")
assert(A.toast:IsVisible() and not page:IsVisible(), "Alerts must appear while the feature window is closed")
assert(A.toast.points[1][3] == "BOTTOM" and A.toast.points[1][5] == UIParent:GetHeight() * 0.3)
AF:CheckAchievements()
assert(#A.queue == 0, "Repeated checks must not award points or queue an alert twice")
A:Refresh()
assert(A.rows[1].earned and not A.rows[1].icon.desaturated)
assert(A.rows[2].icon.desaturated)
A.scroll.scripts.OnMouseWheel(A.scroll, -100)
assert(A.scroll:GetVerticalScroll() == A.maximum)
A.scroll.scripts.OnMouseWheel(A.scroll, 100)
assert(A.scroll:GetVerticalScroll() == 0)
A.scrollbar:SetScrollPercentage(0.5, true)
assert(A.scroll:GetVerticalScroll() == A.maximum / 2, "Scrollbar and wheel must control the same viewport")
-- Multiple earned notifications are displayed in order, then stop updating entirely.
AF.char.total.jumps = 1000
AF.char.total.yards.back = 1000
AF:CheckAchievements()
assert(#A.queue == 2 and AF:GetAchievementPoints() == 30)
A.toast.scripts.OnUpdate(A.toast, 6)
assert(A.current.id == "backpedal")
A.toast.scripts.OnUpdate(A.toast, 6)
assert(A.current.id == "jumpAddict")
A.toast.scripts.OnUpdate(A.toast, 6)
assert(not A.current and not A.toast:IsShown() and not A.toast.scripts.OnUpdate)
local ordered = AF:GetAchievementList()
assert(ordered[1].award.id == "firstSteps" and ordered[2].award.id == "backpedal")
assert(ordered[3].award.id == "jumpAddict" and not ordered[4].earned)
assert(AF.ACHIEVEMENTS[2].id == "touchGrass", "Sorting must not mutate definition order")
local savedDate = AF.char.achievements.backpedal
AF:Init(); AF:Login(); AF:CheckAchievements()
assert(AF.char.achievements.backpedal == savedDate and not A.current and #A.queue == 0)
-- The reset must leave other characters, account preferences and custom goals intact.
local original = AF.char
guid = "Player-Other"; AF:Login(); AF:RecordJump()
local other = AF.char
guid = "Player-Achievements"; AF:Login()
AF.char.goal, AF.char.stride = 500, 2.7
AF.char.activityGoals.jumps = 42
AF.db.showMinimap = false
assert(not A:RequestReset() and AF.char.total.steps >= 50, "No confirmation API must mean no deletion")
StaticPopupDialogs = {}
local popup
StaticPopup_Show = function(key, name, _, data)
  popup = { definition = StaticPopupDialogs[key], name = name, data = data }; return popup
end
assert(A:RequestReset() and popup.name == original.name and popup.definition.hideOnEscape)
assert(AF.char.total.steps >= 50, "Opening or cancelling confirmation must not reset data")
local stale = popup
AF.char = other
stale.definition.OnAccept(nil, stale.data)
assert(other.total.jumps == 1 and original.total.steps >= 50, "Stale confirmation must never reset another character")
AF.char = original
local motionReset, jumpReset = false, false
AF.Motion = { Reset = function() motionReset = true end }
AF.Jump = { Reset = function() jumpReset = true end }
A:Earned(AF.ACHIEVEMENTS[1]); A:Earned(AF.ACHIEVEMENTS[2])
A:RequestReset(); popup.definition.OnAccept(nil, popup.data)
assert(AF.char == original and AF.char.total.steps == 0 and AF.char.total.jumps == 0)
assert(next(AF.char.achievements) == nil and AF:GetAchievementPoints() == 0)
local days = 0; for _ in pairs(AF.char.days) do days = days + 1 end
assert(days == 1 and AF:Today().steps == 0)
assert(AF.char.goal == 500 and AF.char.stride == 2.7 and AF:Today().activityGoals.jumps == 42)
assert(other.total.jumps == 1 and AF.db.showMinimap == false)
assert(motionReset and jumpReset and not A.current and #A.queue == 0 and not A.toast.scripts.OnUpdate)
assert(A.scroll:GetVerticalScroll() == 0)
StaticPopup_Show = function() return nil end
assert(not A:RequestReset() and AF.char.total.steps == 0)
AF:RecordTravel("run", 2.7 * 50, 20, "position")
assert(AF.char.achievements.firstSteps and A.current.id == "firstSteps", "Reset must allow the easy achievement again")
print("PASS: achievement thresholds, points, saved dates, sorting, scroll, hidden-window queued alerts and confirmed character reset")
