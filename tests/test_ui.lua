local Mock = assert(loadfile("tests/ui_mock.lua"))()
date, time = os.date, os.time
GetLocale = function() return "ruRU" end
UnitGUID = function() return "Player-UI" end
UnitName = function() return "Test" end
UnitRace = function() return "Human", "Human" end
local AF = {}
for _, file in ipairs({ "Locale.lua", "LocaleTranslations.lua", "Core.lua", "Achievements.lua", "Minimap.lua", "UI.lua" }) do
  assert(loadfile(file))("AzerothFitness", AF)
end
AF:Init()
AF:Login()
AF.Say = function() end
AF.UI:Init()
local ui = AF.UI
assert(not ui.window:IsShown())
assert(#Mock.tickers == 0, "Do not install a timer for a hidden dashboard")
assert(ui.window.toplevel)
assert(ui.window.template == "PortraitFrameTemplate" and ui.close == ui.window.CloseButton)
assert(ui.title == ui.window.TitleContainer.TitleText and ui.window.NineSlice)
assert(ui.window.PortraitContainer.portrait.texture == AF.ACTIVITY_ICON)
assert(ui.window.surface.solid[4] == 1 and ui.window.Bg.atlas == "Profession-Background-Overview")
assert(ui.window.backdrop == nil and not ui.window.TopTileStreaks:IsShown(), "Do not stack a handmade frame over the native one")
assert(UISpecialFrames[1] == "AzerothFitnessWindow")
assert(ui.title.font == "NativeLocaleFont", "Use the client's font instead of a fixed Latin font file")
assert(ui.title:GetText() == "Azeroth Fitness")
assert(ui.languageLabel == nil and ui.Relocalize == nil, "Do not expose a language selector")
for _, tab in pairs(ui.tabs) do
  assert(tab.template == "LargeSideTabButtonTemplate" and tab.kind == "Frame")
  assert(tab.width == Mock.atlases["common-sidetab"].width and tab.height == Mock.atlases["common-sidetab"].height - 5)
  assert(tab.tooltipText and tab.fillToInterior and tab.Icon.texture)
end
assert(ui.tabs.today.points[1][2] == ui.window and ui.tabs.today.points[1][3] == "TOPRIGHT")
assert(ui.tabs.history.points[1][2] == ui.tabs.today and ui.tabs.history.points[1][3] == "BOTTOMLEFT")

AF:RecordTravel("run", 230, 30, "position")
AF:RecordJump()
ui:Show("today")
assert(ui.window:IsShown() and ui.pages.today:IsShown() and not ui.pages.settings:IsShown())
assert(ui.window.nativeShowRuns == 1, "Preserve native OnShow while fitting the window")
assert(#Mock.tickers == 1 and ui.refreshTicker)
assert(ui.tabs.today.checked and not ui.tabs.history.checked)
local history = ui.tabs.history
history.scripts.OnMouseDown(history, "LeftButton")
history.scripts.OnMouseUp(history, "LeftButton", false)
assert(ui.page == "today" and not history.pressed, "Release outside a tab must reset its native press state without navigating")
history.scripts.OnMouseUp(history, "RightButton", true)
assert(ui.page == "today")
history.scripts.OnMouseDown(history, "LeftButton")
history.scripts.OnMouseUp(history, "LeftButton", true)
assert(ui.page == "history" and history.checked and not ui.tabs.today.checked and history.nativeMouseUpRuns == 3)
ui:Show("today")
ui.headerDrag.scripts.OnDragStart()
assert(ui.window.moving)
ui.headerDrag.scripts.OnDragStop()
assert(not ui.window.moving)
assert(ui.goals.steps.value:GetText() == "100" and ui.goals.steps.target:GetText() == "/ 10 000")
assert(ui.goals.jumps.value:GetText() == "1" and ui.goals.jumps.target:GetText() == "/ 100")
assert(math.abs(ui.goals.steps.bar.status.value - 0.01) < 0.000001)
AF:Today().jumps = 29
ui:Refresh()
assert(ui.goals.jumps.percent:GetText() == "29%", "Do not floor 29 jumps to 28% through floating-point division")
ui.goals.steps.bar:SetProgress(3)
assert(ui.goals.steps.bar.status.value == 1)
ui.goals.steps.bar:SetProgress(-1)
assert(ui.goals.steps.bar.status.value == 0)

ui:Show("settings")
ui.goalInput:SetText("250")
ui.tabs.settings.scripts.OnMouseUp(ui.tabs.settings, "LeftButton", true)
assert(ui.goalInput:GetText() == "250", "Clicking the selected native tab must not reset unsaved fields")
ui.goalInput:SetText("200")
ui.jumpGoalInput:SetText("10")
ui.murloGoalInput:SetText("25")
ui.strideInput:SetText("2,5")
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
assert(AF:T("JUMP_GOAL") == "Цель прыжков на день", "Retired language overrides must not change the client locale")
ui:Show("history")
assert(ui.historyBars[7]:IsShown() and not ui.historyBars[8]:IsShown())
ui.range = 30
ui:Refresh()
assert(ui.historyBars[30]:IsShown() and #ui.historyBars[1].points == 1)
ui:Show("achievements")
assert(AF.Achievements.rows[1].title:GetText() == "Первые шаги")
assert(ui.tabs.achievements.tooltipText == "Достижения")
assert(ui.tabs.achievements.Icon.texture == AF.ACHIEVEMENT_ICON)
assert(ui.best:GetParent() == ui.streak:GetParent() and ui.best:GetParent():GetParent() == ui.pages.history)

UIParent:SetSize(800, 600)
ui:Fit()
assert(ui.window.scale < 1)
ui.close.scripts.OnClick(ui.close)
assert(ui.refreshTicker == nil and Mock.timerHandles[1].cancelled)
local refreshes = 0
local original = ui.Refresh
ui.Refresh = function() refreshes = refreshes + 1 end
Mock.tickers[1]()
assert(refreshes == 0, "Hidden windows must not refresh")
ui.Refresh = original
print("PASS: native templates/font, goal progress, atomic settings, client locale, tabs, Escape registration and hidden refresh")
