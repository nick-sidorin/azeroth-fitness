local _, AF = ...
local A = { queue = {}, rows = {} }
AF.Achievements = A
local ART = "Interface\\AchievementFrame\\"
local function texture(parent, path, width, height, point, relative, x, y)
  local t = parent:CreateTexture(nil, "ARTWORK")
  t:SetTexture(path); t:SetSize(width, height); t:SetPoint(point, parent, relative, x, y)
  return t
end
local function label(parent, width, height, point, relative, x, y, font)
  local t = parent:CreateFontString(nil, "OVERLAY", font or "GameFontHighlight")
  t:SetSize(width, height); t:SetPoint(point, parent, relative, x, y)
  t:SetJustifyH("CENTER")
  return t
end
local function atlas(t, name)
  if C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(name) then t:SetAtlas(name, true) end
end
function A:Build(page)
  self.heading = label(page, 550, 30, "TOP", "TOP", 0, -4, "GameFontNormalLarge")
  local scroll = CreateFrame("ScrollFrame", nil, page)
  scroll:SetPoint("TOPLEFT", 0, -42); scroll:SetSize(534, 462)
  local content = CreateFrame("Frame", nil, scroll)
  content:SetSize(534, math.max(1, #AF.ACHIEVEMENTS * 112))
  scroll:SetScrollChild(content)
  -- The base scroll template has no track/thumb; use the complete native widget.
  local scrollbar = CreateFrame("EventFrame", nil, page, "MinimalScrollBar")
  scrollbar:SetPoint("TOPLEFT", scroll, "TOPRIGHT", 5, 0)
  scrollbar:SetPoint("BOTTOMLEFT", scroll, "BOTTOMRIGHT", 5, 0)
  self.scroll, self.scrollbar = scroll, scrollbar
  self.maximum = math.max(0, #AF.ACHIEVEMENTS * 112 - 462)
  scrollbar:RegisterCallback("OnScroll", function(_, percentage)
    scroll:SetVerticalScroll(percentage * self.maximum)
  end, self)
  scrollbar:Init(math.min(1, 462 / content:GetHeight()), 112 / math.max(1, self.maximum))
  scroll:EnableMouseWheel(true)
  scroll:SetScript("OnMouseWheel", function(_, delta)
    local value = math.max(0, math.min(self.maximum, scroll:GetVerticalScroll() - delta * 56))
    scrollbar:SetScrollPercentage(value / math.max(1, self.maximum), true)
  end)
  for i = 1, #AF.ACHIEVEMENTS do
    local row = CreateFrame("Frame", nil, content)
    row:SetSize(534, 104); row:SetPoint("TOPLEFT", 0, -(i - 1) * 112)
    row.background = texture(row, ART .. "UI-Achievement-Parchment-Horizontal", 534, 104, "TOPLEFT", "TOPLEFT", 0, 0)
    row.background:SetTexCoord(0, 1, 1 - 104 / 256, 1)
    row.titlebar = texture(row, ART .. "UI-Achievement-Borders", 524, 24, "TOPLEFT", "TOPLEFT", 5, -4)
    row.icon = texture(row, AF.ACTIVITY_ICON, 50, 50, "LEFT", "LEFT", 14, 0)
    row.iconFrame = texture(row, ART .. "UI-Achievement-IconFrame", 72, 72, "CENTER", "LEFT", 40, -2)
    row.iconFrame:SetTexCoord(0, 0.5625, 0, 0.5625)
    row.shield = texture(row, ART .. "UI-Achievement-Shields", 66, 64, "RIGHT", "RIGHT", -3, 0)
    row.shield:SetTexCoord(0, 0.5, 0, 0.5)
    row.scoreText = label(row, 42, 30, "CENTER", "RIGHT", -34, 0, "GameFontNormalLarge")
    row.title = label(row, 374, 29, "TOPLEFT", "TOPLEFT", 78, -3)
    row.description = label(row, 374, 42, "TOPLEFT", "TOPLEFT", 78, -32)
    row.date = label(row, 374, 22, "BOTTOMLEFT", "BOTTOMLEFT", 78, 3, "GameFontHighlightSmall")
    self.rows[i] = row
  end
end
function A:Refresh()
  if not self.heading then return end
  local points, available = AF:GetAchievementPoints()
  self.heading:SetText(string.format(AF:T("ACHIEVEMENT_POINTS"), points, available))
  for i, entry in ipairs(AF:GetAchievementList()) do
    local row, award = self.rows[i], entry.award
    row.awardID, row.earned = award.id, entry.earned
    row.background:SetTexture(ART .. (entry.earned and "UI-Achievement-Parchment-Horizontal" or "UI-Achievement-Parchment-Horizontal-Desaturated"))
    if entry.earned then row.titlebar:SetTexCoord(0, 0.9765625, 0.66015625, 0.73828125)
    else row.titlebar:SetTexCoord(0, 1, 0.91796875, 0.99609375) end
    row.icon:SetTexture(award.icon)
    for _, t in ipairs({ row.icon, row.iconFrame, row.shield }) do t:SetDesaturated(not entry.earned) end
    row.scoreText:SetText(award.points)
    row.title:SetText(AF:T("AWARD_" .. award.id))
    row.description:SetText(AF:T("AWARD_DESC_" .. award.id))
    row.date:SetText(entry.earned and string.format(AF:T("EARNED_DATE"), entry.date) or AF:T("NOT_EARNED"))
    local shade = entry.earned and 0.15 or 0.65
    row.title:SetTextColor(entry.earned and 1 or shade, entry.earned and 0.82 or shade, entry.earned and 0.5 or shade)
    row.description:SetTextColor(entry.earned and 0.15 or 0.7, entry.earned and 0.1 or 0.7, entry.earned and 0.05 or 0.7)
    row.date:SetTextColor(shade, shade, shade)
  end
end
function A:BuildToast()
  local frame = CreateFrame("Frame", nil, UIParent)
  frame:SetSize(300, 101); frame:SetFrameStrata("DIALOG"); frame:EnableMouse(false); frame:Hide()
  local bg = texture(frame, ART .. "UI-Achievement-Parchment-Horizontal", 300, 101, "CENTER", "CENTER", 0, 0)
  atlas(bg, "ui-achievement-alert-background")
  frame.icon = texture(frame, AF.ACTIVITY_ICON, 52, 52, "LEFT", "LEFT", 9, -1)
  local border = texture(frame, ART .. "UI-Achievement-IconFrame", 78, 75, "CENTER", "LEFT", 34, -1)
  border:SetTexCoord(0, 0.5625, 0, 0.5625); atlas(border, "ui-achievement-iconframe")
  local shield = texture(frame, ART .. "UI-Achievement-Shields", 64, 64, "RIGHT", "RIGHT", -8, 0)
  shield:SetTexCoord(0, 0.5, 0, 0.5); atlas(shield, "ui-achievement-shield-1")
  frame.title = label(frame, 180, 18, "TOP", "TOP", 7, -20, "GameFontNormalSmall")
  frame.title:SetText(AF:T("TOAST_TITLE"))
  frame.awardName = label(frame, 155, 40, "TOP", "TOP", 7, -36)
  frame.scoreText = label(frame, 35, 30, "CENTER", "RIGHT", -36, -2, "GameFontNormalLarge")
  self.toast = frame
end
function A:ShowNext()
  if self.current or #self.queue == 0 then return end
  if not self.toast then self:BuildToast() end
  local frame = self.toast
  self.current = table.remove(self.queue, 1)
  frame:ClearAllPoints(); frame:SetPoint("CENTER", UIParent, "BOTTOM", 0, UIParent:GetHeight() * 0.3)
  frame.icon:SetTexture(self.current.icon); frame.awardName:SetText(AF:T("AWARD_" .. self.current.id))
  frame.scoreText:SetText(self.current.points)
  local elapsed = 0
  frame:SetAlpha(0); frame:Show()
  frame:SetScript("OnUpdate", function(_, delta)
    elapsed = elapsed + delta
    frame:SetAlpha(math.max(0, math.min(1, elapsed / 0.2, (6 - elapsed) / 1.5)))
    if elapsed >= 6 then
      frame:SetScript("OnUpdate", nil); frame:Hide(); self.current = nil; self:ShowNext()
    end
  end)
end
function A:Earned(award)
  self.queue[#self.queue + 1] = award
  self:ShowNext()
  if AF.UI and AF.UI.page == "achievements" then self:Refresh() end
end
function A:Clear()
  self.queue, self.current = {}, nil
  if self.toast then self.toast:SetScript("OnUpdate", nil); self.toast:Hide() end
  if self.scrollbar then self.scrollbar:SetScrollPercentage(0, true) end
end
function A:RequestReset()
  if type(StaticPopupDialogs) ~= "table" or type(StaticPopup_Show) ~= "function" then
    AF:Say(AF:T("RESET_UNAVAILABLE")); return false
  end
  local key = "AZEROTH_FITNESS_RESET_STATISTICS"
  StaticPopupDialogs[key] = { text = AF:T("RESET_CONFIRM"), button1 = AF:T("RESET_ACCEPT"),
    button2 = AF:T("RESET_CANCEL"), timeout = 0, whileDead = true, hideOnEscape = true,
    OnAccept = function(_, character)
      if character ~= AF.char then return end
      AF:ResetStatistics(); AF:Say(string.format(AF:T("RESET_DONE"), character.name))
    end }
  return StaticPopup_Show(key, AF.char.name, nil, AF.char) ~= nil
end
