local Mock = assert(loadfile("tests/ui_mock.lua"))()
local now = os.time({ year = 2026, month = 11, day = 13, hour = 12 })
date = function(format, timestamp) return os.date(format, timestamp or now) end
time = function(value) return value and os.time(value) or now end
GetLocale = function() return "ruRU" end
local guid = "Minimap-Rings"
UnitGUID = function() return guid end
UnitName = function() return "Tester" end
UnitRace = function() return "Human", "Human" end
local AF = {}
for _, file in ipairs({ "Locale.lua", "LocaleTranslations.lua", "Core.lua", "Achievements.lua", "Minimap.lua", "Rings.lua", "UI.lua" }) do
  assert(loadfile(file))("AzerothFitness", AF)
end
AF.Say = function() end
AF:Init(); AF:Login(); AF.UI:Init()
local mini, ui = AF.MinimapButton, AF.UI
assert(mini.rings and not mini.icon and not mini.border, "The supported shortcut displays only rings")
assert(not ui.window:IsShown() and #Mock.tickers == 0, "Minimap updates must not require the dashboard ticker")
local function near(a, b) assert(math.abs(a - b) < 0.000001, tostring(a) .. " != " .. tostring(b)) end
for id, ring in pairs(mini.rings) do
  assert(ring:GetProgress() == 0 and not ring.scripts.OnUpdate and ring.mouseEnabled == false)
  near(ring.width / ui.goals[id].bar.width, 30 / 260)
  assert(ring.fill.solid[1] == ui.goals[id].bar.fill.solid[1], "Both displays share palette and geometry")
end
AF:RecordTravel("run", 23, 2, "position")
near(mini.rings.steps:GetProgress(), 10 / 10000)
near(mini.rings.murlos:GetProgress(), (23 / 100 * 1.8) / 300)
AF:RecordJump()
near(mini.rings.jumps:GetProgress(), 1 / 100)
assert(not ui.window:IsShown())
assert(AF:SetDailyGoals(100, 10, 25))
near(mini.rings.steps:GetProgress(), 0.1)
near(mini.rings.jumps:GetProgress(), 0.1)
ui:Show("today")
for id, ring in pairs(mini.rings) do near(ring:GetProgress(), ui.goals[id].bar:GetProgress()) end
ui.window:Hide()
local writes = mini.rings.steps.fill.radialWrites
mini:Refresh(); assert(mini.rings.steps.fill.radialWrites == writes)
local midnight = mini.dayTimer
assert(midnight and midnight.delay > 0 and midnight.delay <= 86401)
mini.button:Hide()
assert(midnight.cancelled and not mini.dayTimer)
AF:RecordTravel("run", 23, 2, "position")
assert(mini.rings.steps.fill.radialWrites == writes, "Hidden shortcuts must not redraw")
mini.button:Show()
near(mini.rings.steps:GetProgress(), 0.2)
local active = mini.dayTimer
midnight.callback()
assert(mini.dayTimer == active and not active.cancelled, "Cancelled callbacks must not replace a newer timer")
AF:ResetStatistics()
for _, ring in pairs(mini.rings) do assert(ring:GetProgress() == 0) end
AF:RecordJump(); near(mini.rings.jumps:GetProgress(), 0.1)
local previousDay = AF:DayKey()
local rollover = mini.dayTimer
now = now + rollover.delay
rollover.callback()
assert(AF:DayKey() ~= previousDay and AF.char.days[previousDay].jumps == 1)
for _, ring in pairs(mini.rings) do assert(ring:GetProgress() == 0) end
assert(mini.dayTimer and mini.dayTimer ~= rollover and mini.dayTimer.delay > 0)
-- Refresh on login/character context changes without copying another character's progress.
AF:RecordJump()
guid = "Minimap-Other"; AF:Login()
assert(mini.rings.jumps:GetProgress() == 0)
guid = "Minimap-Rings"; AF:Login()
near(mini.rings.jumps:GetProgress(), 0.1)
-- Tiny ring children must leave the shortcut's existing click/drag handlers intact.
local toggles = 0
local original = ui.Toggle
ui.Toggle = function() toggles = toggles + 1 end
mini.button.scripts.OnClick(mini.button, "LeftButton")
assert(toggles == 1)
mini.button.dragged = true
mini.button.scripts.OnClick(mini.button, "LeftButton")
assert(toggles == 1)
ui.Toggle = original
local old = mini.dayTimer
mini:Init(ui)
assert(old.cancelled and mini.dayTimer ~= old)
assert(mini.button.scripts.OnUpdate == nil and #Mock.tickers == 1,
  "Only the explicitly opened dashboard may have created a refresh ticker")
mini.button:Hide()
assert(not mini.dayTimer)
print("PASS: shared miniature rings, closed-window live updates, goals/reset, hidden cleanup, midnight and character changes")
