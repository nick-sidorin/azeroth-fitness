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

function Shortcut:Refresh(day)
  if not self.button or not self.button:IsVisible() or not self.rings or not AF.char then return end
  day = day or AF:Today()
  local targets = { steps = day.goal, jumps = day.activityGoals.jumps, murlos = day.activityGoals.murlos }
  for id, ring in pairs(self.rings) do ring:SetProgress(day[id] / targets[id]) end
end

function Shortcut:CancelDayTimer()
  self.dayTimerGeneration = (self.dayTimerGeneration or 0) + 1
  if self.dayTimer then self.dayTimer:Cancel(); self.dayTimer = nil end
end

function Shortcut:ScheduleDayReset()
  self:CancelDayTimer()
  if not self.rings or not AF.char or not self.button:IsVisible()
      or not C_Timer or type(C_Timer.NewTimer) ~= "function" then return end
  local now = time()
  local nextDay = date("*t", now)
  nextDay.day, nextDay.hour, nextDay.min, nextDay.sec = nextDay.day + 1, 0, 0, 1
  nextDay.isdst = nil
  local generation = self.dayTimerGeneration
  self.dayTimer = C_Timer.NewTimer(math.max(1, time(nextDay) - now), function()
    if generation ~= self.dayTimerGeneration then return end
    self.dayTimer = nil
    self:Refresh(); self:ScheduleDayReset()
  end)
end

function Shortcut:BuildIcon(button)
  self.rings, self.icon, self.border = nil, nil, nil
  if AF.Rings and AF.Rings:IsSupported(button) then
    local canvas = CreateFrame("Frame", nil, button)
    canvas:SetSize(30, 30); canvas:SetPoint("CENTER"); canvas:EnableMouse(false)
    self.rings = AF.Rings:CreateActivitySet(canvas, 30)
    return
  end
  -- Preserve a usable native shortcut on clients without radial texture support.
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
end

function Shortcut:Init(ui)
  if self.button then self.button:Hide() end
  self:CancelDayTimer()
  local angle = AF.db.minimapAngle
  if type(angle) ~= "number" or angle ~= angle or math.abs(angle) == math.huge then
    AF.db.minimapAngle = 225
  end
  local button = CreateFrame("Button", "AzerothFitnessMinimapButton", Minimap)
  self.button = button
  button:Hide()
  button:SetSize(31, 31)
  button:SetFrameStrata("MEDIUM")
  button:SetFrameLevel(Minimap:GetFrameLevel() + 8)
  button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  button:RegisterForDrag("LeftButton")
  self:BuildIcon(button)

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
  button:SetScript("OnHide", function() stop(); self:CancelDayTimer() end)
  button:SetScript("OnShow", function() self:Refresh(); self:ScheduleDayReset() end)
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
  if Minimap.HookScript and not self.mapSizeHooked then
    Minimap:HookScript("OnSizeChanged", function() self:Position() end)
    self.mapSizeHooked = true
  end
  self:Position()
  button:SetShown(AF.db.showMinimap)
  return button
end
