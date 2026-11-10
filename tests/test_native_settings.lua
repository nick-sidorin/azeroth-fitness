local Mock = assert(loadfile("tests/ui_mock.lua"))()
date, time = os.date, os.time
GetLocale = function() return "enUS" end
UnitGUID = function() return "Player-Settings" end
UnitName = function() return "Test" end
UnitRace = function() return "Human", "Human" end
local AF = {}
for _, file in ipairs({ "Locale.lua", "LocaleTranslations.lua", "Core.lua", "Minimap.lua", "UI.lua" }) do
  assert(loadfile(file))("AzerothFitness", AF)
end
AF:Init(); AF:Login()
local notices = {}
AF.Say = function(_, message) notices[#notices + 1] = message end
AF.UI:Init()
local ui = AF.UI
assert(not ui.settingsCategory, "Missing native APIs must retain the embedded settings fallback")
ui:Show("settings")
assert(ui.window:IsShown() and ui.pages.settings:GetParent() == ui.window)
ui:Show("today")
local runningTimer = ui.refreshTicker

-- Model the actual canvas Settings API appearing after the initial UI setup.
local native = CreateFrame("Frame", nil, UIParent)
local registered, registrations, opens = nil, 0, 0
Settings = {
  RegisterCanvasLayoutCategory = function(frame, name)
    assert(name == "Azeroth Fitness")
    registrations = registrations + 1
    registered = frame
    return { GetID = function() return 123 end }
  end,
  RegisterAddOnCategory = function(category) assert(category:GetID() == 123) end,
  OpenToCategory = function(id)
    assert(id == 123)
    opens = opens + 1
    native:Show()
    registered:SetParent(native)
    registered:Show()
    registered.refresh()
  end,
}
ui:Show("settings")
assert(ui.settingsCategory and registered == ui.pages.settings and registrations == 1 and opens == 1)
assert(not ui.window:IsShown() and runningTimer.cancelled and ui.refreshTicker == nil)
ui.goalInput:SetText("333")
ui:Show("settings")
assert(opens == 1 and ui.goalInput:GetText() == "333", "Repeated open must preserve the same live form's draft")
ui:RegisterNativeSettings()
assert(registrations == 1)

ui.jumpGoalInput:SetText("12")
ui.murloGoalInput:SetText("44")
ui.strideInput:SetText("2.4")
ui.save.scripts.OnClick()
assert(AF.char.goal == 333 and AF.char.activityGoals.jumps == 12)
ui.minimapToggle:SetChecked(false)
ui.minimapToggle.scripts.OnClick(ui.minimapToggle)
assert(not AF.db.showMinimap and not ui.mapButton:IsShown())
registered:Hide(); native:Hide()
assert(AF:SetDailyGoals(444, 13, 45))
ui:Show("settings")
assert(opens == 2 and ui.goalInput:GetText() == "444", "Native reopen must read current saved values")

-- Popup uses a copyable URL only, with actual native edit-box compatibility.
StaticPopupDialogs = {}
local dialog = CreateFrame("Frame")
dialog.EditBox = CreateFrame("EditBox", nil, dialog)
StaticPopup_Show = function(key)
  dialog:Show()
  StaticPopupDialogs[key].OnShow(dialog)
  return dialog
end
assert(ui:ShowSupportLink())
assert(dialog.EditBox:GetText() == "https://github.com/nick-sidorin/azeroth-fitness/issues")
assert(dialog.EditBox.focused and dialog.EditBox.highlighted)
local definition = StaticPopupDialogs.AZEROTH_FITNESS_PROJECT_LINK
definition.EditBoxOnEscapePressed(dialog.EditBox)
assert(not dialog:IsShown())
StaticPopup_Show = nil
assert(not ui:ShowSupportLink() and notices[#notices]:find("https://github.com/nick-sidorin/azeroth-fitness/issues", 1, true))

registered:Hide(); native:Hide()
Settings.OpenToCategory = function() error("unavailable") end
local oldGoal = AF.char.goal
ui:Show("settings")
assert(AF.char.goal == oldGoal and notices[#notices] == AF:T("SETTINGS_UNAVAILABLE"))
print("PASS: native Settings/fallback/late registration, one live form, draft preservation, timer cancellation and copyable support")
