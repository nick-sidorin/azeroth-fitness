local Mock = assert(loadfile("tests/ui_mock.lua"))()
date, time = os.date, os.time
GetLocale = function() return "ruRU" end
UnitGUID = function() return "Player-UI" end
UnitName = function() return "Test" end
UnitRace = function() return "Human", "Human" end
local AF = {}
for _, file in ipairs({ "Locale.lua", "Core.lua", "Minimap.lua", "UI.lua" }) do
  assert(loadfile(file))("AzerothFitness", AF)
end
AF:Init()
AF:Login()
AF.Say = function() end
AF.UI:Init()
local ui = AF.UI
assert(not ui.window:IsShown())
assert(ui.window.template == "BackdropTemplate" and ui.close.template == "UIPanelCloseButton")
assert(UISpecialFrames[1] == "AzerothFitnessWindow")
assert(ui.title.font == "NativeLocaleFont", "Use the client's font instead of a fixed Latin font file")
assert(ui.title:GetText() == "Фитнес Азерота")
for _, tab in pairs(ui.tabs) do assert(tab.template == "UIPanelButtonTemplate") end

AF:RecordTravel("run", 230, 30, "position")
AF:RecordJump()
ui:Show("today")
assert(ui.window:IsShown() and ui.pages.today:IsShown() and not ui.pages.settings:IsShown())
assert(ui.goals.steps.value:GetText() == "100 / 10,000")
assert(ui.goals.jumps.value:GetText() == "1 / 100")
assert(math.abs(ui.goals.steps.bar.status.value - 0.01) < 0.000001)
ui.goals.steps.bar:SetProgress(3)
assert(ui.goals.steps.bar.status.value == 1)
ui.goals.steps.bar:SetProgress(-1)
assert(ui.goals.steps.bar.status.value == 0)

ui:Show("settings")
ui.goalInput:SetText("200")
ui.jumpGoalInput:SetText("10")
ui.murloGoalInput:SetText("25")
ui.strideInput:SetText("2.5")
ui.save.scripts.OnClick()
assert(AF.char.goal == 200 and AF.char.activityGoals.jumps == 10 and AF.char.stride == 2.5)
assert(AF:Today().activityGoals.murlos == 25)
ui.strideInput:SetText("bad")
ui.goalInput:SetText("500")
ui.save.scripts.OnClick()
assert(AF.char.goal == 200, "Invalid settings must leave the complete saved configuration unchanged")
ui.minimapToggle:SetChecked(false)
ui.minimapToggle.scripts.OnClick(ui.minimapToggle)
assert(not AF.db.showMinimap and not ui.mapButton:IsShown())

AF.db.language = "en"
ui:Relocalize()
assert(ui.title:GetText() == "Azeroth Fitness" and ui.jumpGoalLabel:GetText() == "Daily jump goal")
ui:Show("history")
assert(ui.historyBars[7]:IsShown() and not ui.historyBars[8]:IsShown())
ui.range = 30
ui:Refresh()
assert(ui.historyBars[30]:IsShown() and #ui.historyBars[1].points == 1)
ui:Show("records")
assert(not ui.awards[1]:GetText():find("AWARD_", 1, true))
AF.db.language = "ru"
ui:Relocalize()
ui:Refresh()
assert(ui.awards[1]:GetText():find("Потрогай траву", 1, true))

UIParent:SetSize(800, 600)
ui:Fit()
assert(ui.window.scale < 1)
ui.close.scripts.OnClick()
local refreshes = 0
local original = ui.Refresh
ui.Refresh = function() refreshes = refreshes + 1 end
Mock.tickers[1]()
assert(refreshes == 0, "Hidden windows must not refresh")
ui.Refresh = original
print("PASS: native templates/font, goal progress, atomic settings, locale switching, tabs, Escape registration and hidden refresh")
