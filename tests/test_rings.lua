local Mock = assert(loadfile("tests/ui_mock.lua"))()
local AF = {}
assert(loadfile("Rings.lua"))("AzerothFitness", AF)
assert(AF.Rings:IsSupported(UIParent))
local ring = AF.Rings:Create(UIParent, 100, 10, { 1, 0.2, 0.3 }, { 0.02, 0.02, 0.02 })
assert(ring.track.mask and ring.fill.mask and ring.hole.mask)
assert(ring.hole.width == 80 and ring.startCap.width == 10)
assert(ring.fill.rotation == math.pi and ring.fill.radialReverse == false)
assert(ring:GetProgress() == 0 and not ring.fill:IsShown() and not ring.endCap:IsShown())
local function near(a, b) assert(math.abs(a - b) < 0.000001) end
for _, entry in ipairs({ { 0.25, 45, 0 }, { 0.5, 0, -45 }, { 0.75, -45, 0 } }) do
  ring:SetProgress(entry[1])
  assert(ring.fill.radialPercent == entry[1] and ring.fill:IsShown() and ring.endCap:IsShown())
  near(ring.endCap.points[1][4], entry[2]); near(ring.endCap.points[1][5], entry[3])
end
ring:SetProgress(1)
assert(ring.fill.radialPercent == 1 and not ring.endCap:IsShown() and not ring.startCap:IsShown())
local writes = ring.fill.radialWrites
ring:SetProgress(5)
assert(ring:GetProgress() == 1 and ring.fill.radialWrites == writes, "Avoid unchanged writes and clamp over-goal display")
ring:SetProgress(-1)
assert(ring:GetProgress() == 0 and not ring.fill:IsShown())
assert(not ring.scripts.OnUpdate, "Static radial progress must not create a permanent animation/polling driver")
-- The real dashboard must update rings and preserve the original capability fallback.
for _, supported in ipairs({ true, false }) do
  Mock = assert(loadfile("tests/ui_mock.lua"))()
  if not supported then Mock.methods.SetRadialProgressBarPercent = nil end
  date, time = os.date, os.time
  GetLocale = function() return "ruRU" end
  UnitGUID = function() return "Rings-Test" end
  UnitName = function() return "Tester" end
  UnitRace = function() return "Human", "Human" end
  AzerothFitnessDB = nil
  local addon = {}
  for _, file in ipairs({ "Locale.lua", "LocaleTranslations.lua", "Core.lua", "Achievements.lua", "Minimap.lua", "Rings.lua", "UI.lua" }) do
    assert(loadfile(file))("AzerothFitness", addon)
  end
  addon.Say = function() end
  addon:Init(); addon:Login(); addon.UI:Init()
  local ui = addon.UI
  assert(ui.usesRings == supported)
  local today = addon:Today()
  today.steps, today.jumps, today.murlos = 2500, 50, 225
  ui:Show("today")
  near(ui.goals.steps.bar:GetProgress(), 0.25)
  near(ui.goals.jumps.bar:GetProgress(), 0.5)
  near(ui.goals.murlos.bar:GetProgress(), 0.75)
  assert(ui.goals.steps.percent:GetText() == "25%" and ui.goals.murlos.value:GetText() == "225,0")
  today.steps = 15000; ui:Refresh()
  assert(ui.goals.steps.bar:GetProgress() == 1 and ui.goals.steps.percent:GetText() == "150%")
  if supported then
    assert(ui.goals.murlos.bar.width > ui.goals.steps.bar.width and ui.goals.steps.bar.width > ui.goals.jumps.bar.width)
    assert(ui.goals.murlos.bar.level < ui.goals.steps.bar.level and ui.goals.steps.bar.level < ui.goals.jumps.bar.level)
    local previous = ui.goals.steps.bar.fill.radialWrites
    ui:Refresh(); assert(ui.goals.steps.bar.fill.radialWrites == previous)
    ui.window:Hide(); today.steps = 5000; ui:Refresh()
    assert(ui.goals.steps.bar.fill.radialWrites == previous, "Hidden dashboards must not redraw rings")
  else
    assert(ui.goals.steps.bar.status and not ui.ringPanel, "Unsupported radial APIs keep the working native bars")
  end
  ui.window:Hide()
  assert(ui.refreshTicker == nil)
end
print("PASS: native radial values/caps, nesting, clamping, unchanged/hidden work avoidance and linear-bar fallback")
