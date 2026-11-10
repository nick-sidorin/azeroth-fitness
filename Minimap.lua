local _, AF = ...
local Shortcut = {}
AF.MinimapButton = Shortcut
AF.ACTIVITY_ICON = "Interface\\Icons\\Ability_Rogue_Sprint"

function Shortcut:Position()
  local radians = math.rad(AF.db.minimapAngle or 225)
  local x = math.cos(radians) * (Minimap:GetWidth() / 2 + 8)
  local y = math.sin(radians) * (Minimap:GetHeight() / 2 + 8)
  self.button:ClearAllPoints()
  self.button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

function Shortcut:UpdateDrag()
  local cursorX, cursorY = GetCursorPosition()
  local centerX, centerY = Minimap:GetCenter()
  if not centerX or not centerY then return end
  local scale = Minimap:GetEffectiveScale()
  local x = (cursorX / scale - centerX) / (Minimap:GetWidth() / 2 + 8)
  local y = (cursorY / scale - centerY) / (Minimap:GetHeight() / 2 + 8)
  if x == 0 and y == 0 then return end
  AF.db.minimapAngle = math.deg(math.atan2(y, x)) % 360
  self:Position()
end

function Shortcut:Init(ui)
  local angle = AF.db.minimapAngle
  if type(angle) ~= "number" or angle ~= angle or math.abs(angle) == math.huge then
    AF.db.minimapAngle = 225
  end
  local button = CreateFrame("Button", "AzerothFitnessMinimapButton", Minimap)
  self.button = button
  button:SetSize(31, 31)
  button:SetFrameStrata("MEDIUM")
  button:SetFrameLevel(Minimap:GetFrameLevel() + 8)
  button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  button:RegisterForDrag("LeftButton")
  local background = button:CreateTexture(nil, "BACKGROUND")
  background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
  background:SetSize(24, 24)
  background:SetPoint("TOPLEFT", 3, -3)
  local icon = button:CreateTexture(nil, "ARTWORK")
  icon:SetTexture(AF.ACTIVITY_ICON)
  icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
  icon:SetSize(20, 20)
  icon:SetPoint("TOPLEFT", 7, -5)
  local mask = button:CreateMaskTexture()
  mask:SetAllPoints(icon)
  mask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
  icon:AddMaskTexture(mask)
  local border = button:CreateTexture(nil, "OVERLAY")
  border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
  border:SetSize(53, 53)
  border:SetPoint("TOPLEFT")
  button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight", "ADD")
  self.icon, self.border = icon, border

  local function stop()
    button.dragging = false
    button:SetScript("OnUpdate", nil)
  end
  button:SetScript("OnMouseDown", function() button.dragged = false end)
  button:SetScript("OnDragStart", function()
    button.dragging, button.dragged = true, true
    GameTooltip:Hide()
    self:UpdateDrag()
    -- Cursor tracking exists only for the duration of a user drag.
    button:SetScript("OnUpdate", function() self:UpdateDrag() end)
  end)
  button:SetScript("OnDragStop", stop)
  button:SetScript("OnHide", stop)
  button:SetScript("OnClick", function(_, mouseButton)
    if button.dragged then return end
    if mouseButton == "RightButton" then ui:Show("settings") else ui:Toggle() end
  end)
  button:SetScript("OnEnter", function()
    if button.dragging then return end
    GameTooltip:SetOwner(button, "ANCHOR_LEFT")
    GameTooltip:SetText(AF:T("TITLE"))
    GameTooltip:AddLine(AF:T("MINIMAP_HINT"), 1, 1, 1, true)
    GameTooltip:Show()
  end)
  button:SetScript("OnLeave", function() GameTooltip:Hide() end)
  if Minimap.HookScript then Minimap:HookScript("OnSizeChanged", function() self:Position() end) end
  self:Position()
  button:SetShown(AF.db.showMinimap)
  return button
end
