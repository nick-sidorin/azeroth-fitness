local _, AF = ...
local A = { queue = {}, rows = {} }
AF.Achievements = A
local ART = "Interface\\AchievementFrame\\"
local function texture(parent, path, width, height, point, relative, x, y, layer)
  local t = parent:CreateTexture(nil, layer or "ARTWORK")
  if path then t:SetTexture(path) end
  t:SetSize(width, height); t:SetPoint(point, parent, relative, x, y)
  return t
end
local function label(parent, width, height, point, relative, x, y, font)
  local t = parent:CreateFontString(nil, "OVERLAY", font or "GameFontHighlight")
  t:SetSize(width, height); t:SetPoint(point, parent, relative, x, y)
  t:SetJustifyH("CENTER"); t:SetJustifyV("MIDDLE")
  t:SetShadowColor(0, 0, 0, 1); t:SetShadowOffset(1, -1)
  return t
end
local function atlas(t, name)
  if C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(name) then
    -- Explicitly replace UVs; a file-sheet crop is invalid on an atlas region.
    t:SetAtlas(name, true, "LINEAR", true)
    return true
  end
  return false
end
local function inset(parent, width, height, x, y)
  local frame = CreateFrame("Frame", nil, parent, "InsetFrameTemplate")
  frame:SetSize(width, height); frame:SetPoint("TOPLEFT", x, y)
  local base = frame:CreateTexture(nil, "BACKGROUND", nil, -8)
  frame.surface = base
  base:SetAllPoints(frame.Bg); base:SetColorTexture(0.08, 0.065, 0.04, 1)
  if C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo("Professions-background-summarylist") then
    frame.Bg:SetAtlas("Professions-background-summarylist", false, "LINEAR", true)
  end
  return frame
end
local function icon(parent, width, height, point, relative, x, y, alert)
  local holder = CreateFrame("Frame", nil, parent)
  holder:SetSize(width, height); holder:SetPoint(point, parent, relative, x, y)
  local image = texture(holder, AF.ACTIVITY_ICON, alert and 52 or 50, alert and 52 or 50,
    "CENTER", "CENTER", 0, alert and 0 or 3)
  local border = texture(holder, nil, 72, 72, "CENTER", "CENTER", -1, 2, "OVERLAY")
  if not atlas(border, "ui-achievement-iconframe") then
    border:SetTexture(ART .. "UI-Achievement-IconFrame")
    border:SetTexCoord(0, 0.5625, 0, 0.5625)
  end
  return image, border, holder
end
local function shield(parent, alert)
  local holder = CreateFrame("Frame", nil, parent)
  holder:SetSize(64, 64)
  holder:SetPoint(alert and "TOPRIGHT" or "RIGHT", parent, alert and "TOPRIGHT" or "RIGHT",
    alert and -8 or -10, alert and -15 or 0)
  local image = texture(holder, nil, 66, 64, "TOPRIGHT", "TOPRIGHT", 1, -6, "BACKGROUND")
  if not atlas(image, "ui-achievement-shield-1") then
    image:SetTexture(ART .. "UI-Achievement-Shields"); image:SetTexCoord(0, 0.5, 0, 0.5)
  end
  local points = label(holder, 42, 18, "CENTER", "CENTER", 3, -2, "GameFontNormal")
  if alert then
    -- Center on the shield artwork, whose top inset differs from its container.
    points:ClearAllPoints(); points:SetPoint("CENTER", image, "CENTER", 3, 0)
  end
  return image, points, holder
end
local function achievementCard(parent, width, height, y)
  -- The same tooltip-border artwork frames Blizzard's own achievement cards.
  local row = CreateFrame("Frame", nil, parent, "BackdropTemplate")
  row:SetSize(width, height); row:SetPoint("TOPLEFT", 0, y)
  row:SetBackdrop({ edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12 })
  row.surface = row:CreateTexture(nil, "BACKGROUND", nil, -8)
  row.surface:SetPoint("TOPLEFT", 4, -4); row.surface:SetPoint("BOTTOMRIGHT", -4, 4)
  row.surface:SetColorTexture(0.06, 0.045, 0.025, 1)
  row.background = texture(row, ART .. "UI-Achievement-Parchment-Horizontal", width - 8, height - 8,
    "TOPLEFT", "TOPLEFT", 4, -4, "BACKGROUND")
  -- Crop at approximately native texel density instead of flattening a tall pane atlas.
  row.background:SetTexCoord(0, 1, 1 - (height - 8) / 256, 1)
  row.shade = texture(row, nil, width - 8, height - 8, "TOPLEFT", "TOPLEFT", 4, -4, "BACKGROUND")
  row.titlebar = texture(row, ART .. "UI-Achievement-Borders", width - 12, 24,
    "TOPLEFT", "TOPLEFT", 6, -5)
  return row
end
function A:Build(page)
  self.pointsFrame = inset(page, 560, 38, 0, -4)
  self.pointsBar = CreateFrame("StatusBar", nil, self.pointsFrame)
  self.pointsBar:SetPoint("TOPLEFT", 10, -9); self.pointsBar:SetSize(540, 20)
  self.pointsBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
  self.pointsBar:SetStatusBarColor(0.76, 0.55, 0.16)
  self.pointsTrack = texture(self.pointsBar, "Interface\\TargetingFrame\\UI-StatusBar", 540, 20,
    "CENTER", "CENTER", 0, 0, "BACKGROUND")
  self.pointsTrack:SetVertexColor(0.20, 0.16, 0.08, 1)
  self.heading = label(self.pointsBar, 530, 20, "CENTER", "CENTER", 0, 0)
  self.listFrame = inset(page, 560, 452, 0, -56)
  local scroll = CreateFrame("ScrollFrame", nil, self.listFrame)
  scroll:SetPoint("TOPLEFT", 8, -8); scroll:SetSize(524, 436)
  local content = CreateFrame("Frame", nil, scroll)
  content:SetSize(524, math.max(1, #AF.ACHIEVEMENTS * 112))
  scroll:SetScrollChild(content)
  -- The base scroll template has no track/thumb; use the complete native widget.
  local scrollbar = CreateFrame("EventFrame", nil, self.listFrame, "MinimalScrollBar")
  scrollbar:SetPoint("TOPLEFT", scroll, "TOPRIGHT", 11, 0)
  scrollbar:SetPoint("BOTTOMLEFT", scroll, "BOTTOMRIGHT", 11, 0)
  self.scroll, self.scrollbar = scroll, scrollbar
  self.maximum = math.max(0, #AF.ACHIEVEMENTS * 112 - 436)
  scrollbar:RegisterCallback("OnScroll", function(_, percentage)
    scroll:SetVerticalScroll(percentage * self.maximum)
  end, self)
  scrollbar:Init(math.min(1, 436 / content:GetHeight()), 112 / math.max(1, self.maximum))
  scroll:EnableMouseWheel(true)
  scroll:SetScript("OnMouseWheel", function(_, delta)
    local value = math.max(0, math.min(self.maximum, scroll:GetVerticalScroll() - delta * 56))
    scrollbar:SetScrollPercentage(value / math.max(1, self.maximum), true)
  end)
  for i = 1, #AF.ACHIEVEMENTS do
    local row = achievementCard(content, 524, 104, -(i - 1) * 112)
    row.icon, row.iconFrame, row.iconHolder = icon(row, 60, 60, "LEFT", "LEFT", 10, 0)
    row.shield, row.scoreText, row.shieldHolder = shield(row, false)
    row.title = label(row, 356, 24, "TOPLEFT", "TOPLEFT", 82, -7, "GameFontHighlightMedium")
    row.description = label(row, 356, 34, "TOPLEFT", "TOPLEFT", 82, -36)
    row.date = label(row, 356, 18, "BOTTOMLEFT", "BOTTOMLEFT", 82, 10, "GameFontHighlightSmall")
    row.title:SetJustifyH("LEFT"); row.description:SetJustifyH("LEFT"); row.date:SetJustifyH("LEFT")
    self.rows[i] = row
  end
end
function A:Refresh()
  if not self.heading then return end
  local points, available = AF:GetAchievementPoints()
  self.pointsBar:SetMinMaxValues(0, math.max(1, available))
  self.pointsBar:SetValue(points)
  self.heading:SetText(string.format(AF:T("ACHIEVEMENT_POINTS"), points, available))
  for i, entry in ipairs(AF:GetAchievementList()) do
    local row, award = self.rows[i], entry.award
    row.awardID, row.earned = award.id, entry.earned
    local shade = entry.earned and 1 or 0.65
    row.background:SetTexture(ART .. (entry.earned and "UI-Achievement-Parchment-Horizontal"
      or "UI-Achievement-Parchment-Horizontal-Desaturated"))
    row.shade:SetColorTexture(0, 0, 0, entry.earned and 0.40 or 0.52)
    if entry.earned then
      row.titlebar:SetTexCoord(0, 0.9765625, 0.66015625, 0.73828125)
      row:SetBackdropBorderColor(0.72, 0.55, 0.28, 1)
    else
      row.titlebar:SetTexCoord(0, 1, 0.91796875, 0.99609375)
      row:SetBackdropBorderColor(0.42, 0.39, 0.32, 1)
    end
    row.titlebar:SetVertexColor(1, 1, 1, 0.65)
    row.icon:SetTexture(award.icon)
    for _, t in ipairs({ row.icon, row.iconFrame, row.shield }) do t:SetDesaturated(not entry.earned) end
    row.scoreText:SetText(award.points)
    row.scoreText:SetTextColor(entry.earned and 1 or 0.65, entry.earned and 0.82 or 0.65, entry.earned and 0.3 or 0.65)
    row.title:SetText(AF:T("AWARD_" .. award.id))
    row.description:SetText(AF:T("AWARD_DESC_" .. award.id))
    row.date:SetText(entry.earned and string.format(AF:T("EARNED_DATE"), entry.date) or AF:T("NOT_EARNED"))
    row.title:SetTextColor(shade, shade, shade)
    row.description:SetTextColor(shade, shade, shade)
    row.date:SetTextColor(entry.earned and 0.84 or 0.6, entry.earned and 0.76 or 0.6, entry.earned and 0.58 or 0.6)
  end
end
function A:BuildToast()
  local frame = CreateFrame("Frame", nil, UIParent)
  frame:SetSize(300, 101); frame:SetFrameStrata("DIALOG"); frame:EnableMouse(false); frame:Hide()
  frame.background = texture(frame, nil, 300, 101, "CENTER", "CENTER", 0, 0, "BACKGROUND")
  if not atlas(frame.background, "ui-achievement-alert-background") then
    -- A complete native frame replaces the entire missing atlas, never a cropped sheet.
    frame.fallback = inset(frame, 300, 76, 0, -15)
    frame.fallback:SetFrameLevel(frame:GetFrameLevel())
  end
  -- Match the authored alert's subframes, anchors, draw layers and font areas.
  frame.icon, frame.iconFrame, frame.iconHolder = icon(frame, 78, 75, "TOPLEFT", "TOPLEFT", -4, -15, true)
  frame.shield, frame.scoreText, frame.shieldHolder = shield(frame, true)
  frame.title = label(frame, 200, 12, "TOP", "TOP", 7, -23, "GameFontBlackTiny")
  frame.title:SetShadowOffset(0, 0); frame.title:SetText(AF:T("TOAST_TITLE"))
  frame.awardName = label(frame, 155, 36, "TOP", "TOP", 7, -35)
  frame.awardName:SetTextColor(1, 1, 1); frame.awardName:SetMaxLines(2)
  if frame.fallback then
    frame.title:SetTextColor(1, 0.82, 0.3); frame.title:SetShadowOffset(1, -1)
  end
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
