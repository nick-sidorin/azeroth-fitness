local Mock = assert(loadfile("tests/ui_mock.lua"))()
date, time = os.date, os.time
GetLocale = function() return "enUS" end
UnitGUID = function() return "Navigation-Test" end
UnitName = function() return "Tester" end
UnitRace = function() return "Human", "Human" end
local AF = {}
for _, file in ipairs({ "Locale.lua", "LocaleTranslations.lua", "Core.lua", "Achievements.lua", "Minimap.lua", "UI.lua" }) do
  assert(loadfile(file))("AzerothFitness", AF)
end
AF.Say = function() end
AF:Init(); AF:Login(); AF.UI:Init()
local A, ui = AF.Achievements, AF.UI
local awards = {}; for _, award in ipairs(AF.ACHIEVEMENTS) do awards[award.id] = award end
local function near(a, b) assert(math.abs(a - b) < 0.000001, tostring(a) .. " != " .. tostring(b)) end
AF.char.total.steps = 25.75
local current, target = AF:GetAchievementProgress(awards.firstSteps)
assert(current == 25.75 and target == 50 and AF:FormatAchievementProgress(awards.firstSteps) == "25 / 50")
AF:CheckAchievements()
assert(not AF.char.achievements.firstSteps, "A displayed counter must not unlock a fractional step early")
AF:Today().steps = 1234
AF.char.total.jumps = 456
AF.char.total.yards.back = 321
AF.char.total.yards.strafeLeft, AF.char.total.yards.strafeRight = 100, 200
assert(AF:GetAchievementProgress(awards.stillSitting) == 1234)
assert(AF:GetAchievementProgress(awards.jumpAddict) == 456)
assert(AF:GetAchievementProgress(awards.backpedal) == 321)
assert(AF:FormatAchievementProgress(awards.backpedal) == "321 / 1,000 yd")
near(AF:GetAchievementProgress(awards.crabMode), 300 * AF.METERS_PER_YARD)
near(AF:GetAchievementProgress(awards.marathon), AF:FootYards(AF.char.total) * AF.METERS_PER_YARD)
assert(AF:FormatAchievementProgress(awards.crabMode):find(" / 10,000 m", 1, true))
AF.char.total.steps = 20000
assert(AF:GetAchievementProgress(awards.touchGrass) == 10000, "Overshoot must clamp to the goal")
AF.char.achievements.couch = AF:DayKey()
assert(AF:Streak() == 0 and AF:GetAchievementProgress(awards.couch) == 7,
  "An earned streak award must remain complete after its active streak expires")
A:Refresh()
assert(A.rows[1].awardID == "couch" and A.rows[1].progress.value == 7 and not A.rows[1].progress:IsShown())
local found
for _, row in ipairs(A.rows) do
  if row.awardID == "jumpAddict" then found = row; break end
end
assert(found.progress.maximum == 1000 and found.progress.value == 456 and found.progressText:GetText() == "456 / 1,000")
-- Click the last of eight earned rows; navigation must use sorted IDs, not definition position or stale closures.
for _, award in ipairs(AF.ACHIEVEMENTS) do AF.char.achievements[award.id] = AF:DayKey() end
A:Earned(awards.couch); A:Earned(awards.firstSteps)
assert(not ui.window:IsShown())
local toast = A.toast
assert(toast.kind == "Button" and toast.mouseEnabled and toast.clickButtons[1] == "LeftButtonUp")
toast.scripts.OnEnter(toast)
assert(GameTooltip:GetOwner() == toast and GameTooltip:GetText() == AF:T("TOAST_OPEN"))
toast.scripts.OnClick(toast, "RightButton")
assert(not ui.window:IsShown() and A.current.id == "couch")
toast.scripts.OnClick(toast, "LeftButton")
assert(ui.window:IsShown() and ui.page == "achievements" and A.focusedID == "couch")
assert(A.focusedIndex == 8 and A.scroll:GetVerticalScroll() == A.maximum)
assert(A.rows[8].awardID == "couch" and A.rows[8].borderColor[1] == 1)
assert(A.current.id == "firstSteps" and #A.queue == 0, "Clicking must advance, not discard, queued notifications")
assert(not GameTooltip:IsShown(), "Dismissal must clean up its owned tooltip")
-- A timer refresh must not pull the user back after manually scrolling away.
A.scrollbar:SetScrollPercentage(0, true); ui:Refresh()
assert(A.scroll:GetVerticalScroll() == 0)
ui.window:Hide()
toast.scripts.OnClick(toast, "LeftButton")
assert(ui.window:IsShown() and A.focusedID == "firstSteps" and A.focusedIndex == 1)
assert(A.scroll:GetVerticalScroll() == 0 and not A.current and not toast.scripts.OnUpdate)
local oldFocus = A.focusedID
assert(not A:Open("unknown-id") and A.focusedID == oldFocus)
-- Reordering after a different award is earned must retain the selected ID.
AF.char.achievements = { couch = AF:DayKey() }
A:Open("couch"); assert(A.focusedIndex == 1)
AF.char.achievements.firstSteps = AF:DayKey(); ui:Refresh()
assert(A.focusedID == "couch" and A.focusedIndex == 2 and A.scroll:GetVerticalScroll() == 112)
A:Earned(awards.couch)
GameTooltip:SetOwner(ui.window); GameTooltip:Show()
toast.scripts.OnLeave(toast)
assert(GameTooltip:IsShown(), "Toast cleanup must not hide another frame's tooltip")
AF:ResetStatistics()
assert(not A.focusedID and not A.focusedIndex and A.scroll:GetVerticalScroll() == 0)
for _, row in ipairs(A.rows) do
  assert(row.progress.value == 0 and row.progress:IsShown() and not row.date:IsShown())
  assert(row.description.shadowColor[4] == 1 and row.description.tint[1] > 0.7,
    "Reused rows must restore unfinished-card text styling")
end
-- A notification remains available if the window is temporarily unavailable.
A:Earned(awards.firstSteps)
local window = ui.window; ui.window = nil
toast.scripts.OnClick(toast, "LeftButton")
assert(A.current.id == "firstSteps" and toast:IsShown())
ui.window = window
A:Clear()
print("PASS: metric progress/units, earned completion, clickable queued alerts, sorted-ID navigation, focus, manual scroll and reset")
