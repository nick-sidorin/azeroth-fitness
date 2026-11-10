local Mock = assert(loadfile("tests/ui_mock.lua"))()
local cursorX, cursorY = 0, 0
GetCursorPosition = function() return cursorX, cursorY end
local AF = { db = { showMinimap = true }, T = function(_, key) return key end }
assert(loadfile("Minimap.lua"))("AzerothFitness", AF)
local calls = 0
local ui = { Toggle = function() calls = calls + 1 end,
  Show = function(_, page) assert(page == "settings"); calls = calls + 10 end }
local button = AF.MinimapButton:Init(ui)
local function near(actual, expected) assert(math.abs(actual - expected) < 0.000001) end
assert(button.parent == Minimap and button.shown)
assert(AF.MinimapButton.icon.mask and AF.MinimapButton.icon.texture == AF.ACTIVITY_ICON)
assert(AF.MinimapButton.border.texture == "Interface\\Minimap\\MiniMap-TrackingBorder")
assert(button.scripts.OnUpdate == nil)
button.scripts.OnClick(button, "LeftButton")
button.scripts.OnClick(button, "RightButton")
assert(calls == 11)

-- Cursor pixels must be converted to map coordinates before calculating angle.
Minimap:SetScale(0.8)
cursorX, cursorY = (100 + 108) * 0.8, 100 * 0.8
button.scripts.OnDragStart(button)
near(AF.db.minimapAngle, 0)
near(button.points[1][4], 108)
near(button.points[1][5], 0)
cursorX, cursorY = 100 * 0.8, (100 + 108) * 0.8
button.scripts.OnUpdate(button)
near(AF.db.minimapAngle, 90)
button.scripts.OnDragStop(button)
assert(button.scripts.OnUpdate == nil and not button.dragging)
button.scripts.OnClick(button, "LeftButton")
assert(calls == 11, "Finishing a drag must not open the window")
button.scripts.OnMouseDown(button)
button.scripts.OnClick(button, "LeftButton")
assert(calls == 12)

-- Position survives rebuilding the shortcut and adapts to a resized map.
local restored = AF.MinimapButton:Init(ui)
near(AF.db.minimapAngle, 90)
Minimap:SetSize(300, 300)
Minimap.scripts.OnSizeChanged(Minimap)
near(restored.points[1][5], 158)
restored.scripts.OnDragStart(restored)
restored:Hide()
assert(restored.scripts.OnUpdate == nil and not restored.dragging)
assert(#Mock.tickers == 0, "The shortcut must not install a permanent ticker")
print("PASS: masked native minimap icon, scaled drag, click suppression, saved angle, resize and drag cleanup")
