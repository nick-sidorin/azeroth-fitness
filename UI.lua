local _, AF = ...
local UI = {}
AF.UI = UI

local W, H = 600, 650
local C = {
  gold = { 0.93, 0.78, 0.47 }, white = { 0.96, 0.92, 0.83 }, muted = { 0.67, 0.63, 0.53 },
  steps = { 0.65, 0.90, 0.20 }, jumps = { 0.15, 0.78, 0.94 }, murlos = { 0.95, 0.26, 0.36 },
}
local function color(fs, c) fs:SetTextColor(c[1], c[2], c[3]) end
local function text(parent, value, size, tint, justify)
  local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  -- Use the client's locale-aware face; hardcoded FRIZQT lacks Cyrillic in ruRU.
  local face, _, flags = GameFontHighlight:GetFont()
  fs:SetFont(face, size or 13, flags or "")
  fs:SetText(value or "")
  fs:SetJustifyH(justify or "LEFT")
  color(fs, tint or C.white)
  return fs
end
local function line(parent, x, y, width, value, size, tint)
  local fs = text(parent, value, size, tint)
  fs:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
  fs:SetWidth(width)
  return fs
end
local function stone(parent, width, height, shade)
  -- The dialog background has transparent pixels. Guarantee opacity separately.
  local base = parent:CreateTexture(nil, "BACKGROUND", nil, -2)
  base:SetPoint("TOPLEFT", 5, -5)
  base:SetPoint("BOTTOMRIGHT", -5, 5)
  base:SetColorTexture(0.055, 0.042, 0.028, 1)
  local grain = parent:CreateTexture(nil, "BACKGROUND", nil, -1)
  grain:SetAllPoints(base)
  grain:SetTexture("Interface\\FrameGeneral\\UI-Background-Marble")
  grain:SetHorizTile(true)
  grain:SetVertTile(true)
  grain:SetTexCoord(0, width / 256, 0, height / 256)
  grain:SetVertexColor(shade, shade * 0.83, shade * 0.62, 1)
  parent.surface, parent.grain = base, grain
end
local function panel(parent, x, y, width, height)
  local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
  frame:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
  frame:SetSize(width, height)
  frame:SetBackdrop({ edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 } })
  stone(frame, width, height, 0.48)
  frame:SetBackdropBorderColor(0.47, 0.38, 0.22)
  return frame
end
local function button(parent, label, x, y, width, height, click)
  local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
  b:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
  b:SetSize(width, height)
  b:SetText(label)
  b:SetScript("OnClick", click)
  function b:SetLabel(value) self:SetText(value) end
  return b
end
local function bar(parent, x, y, width, height, tint)
  local surround = panel(parent, x, y, width, height)
  local status = CreateFrame("StatusBar", nil, surround)
  status:SetPoint("TOPLEFT", 4, -4)
  status:SetPoint("BOTTOMRIGHT", -4, 4)
  status:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
  status:SetStatusBarColor(tint[1], tint[2], tint[3])
  status:SetMinMaxValues(0, 1)
  status:SetValue(0)
  function surround:SetProgress(value) status:SetValue(math.max(0, math.min(1, value or 0))) end
  surround.status = status
  return surround
end

function UI:Fit()
  self.window:SetScale(math.min(1, UIParent:GetWidth() * 0.94 / W, UIParent:GetHeight() * 0.94 / H))
end

function UI:Build()
  local window = CreateFrame("Frame", "AzerothFitnessWindow", UIParent, "BackdropTemplate")
  self.window = window
  window:Hide()
  window:SetSize(W, H)
  window:SetPoint("CENTER")
  window:SetFrameStrata("DIALOG")
  window:SetClampedToScreen(true)
  window:EnableMouse(true)
  window:SetMovable(true)
  window:SetBackdrop({ edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border", edgeSize = 32,
    insets = { left = 10, right = 10, top = 10, bottom = 10 } })
  stone(window, W, H, 0.70)
  local header = panel(window, 12, -12, 576, 62)
  header:SetBackdropBorderColor(0.60, 0.46, 0.23)
  local drag = CreateFrame("Frame", nil, window)
  drag:SetPoint("TOPLEFT", 12, -8)
  drag:SetPoint("TOPRIGHT", -42, -8)
  drag:SetHeight(64)
  drag:EnableMouse(true)
  drag:RegisterForDrag("LeftButton")
  drag:SetScript("OnDragStart", function() window:StartMoving() end)
  drag:SetScript("OnDragStop", function() window:StopMovingOrSizing() end)
  local emblem = drag:CreateTexture(nil, "ARTWORK")
  emblem:SetSize(34, 34)
  emblem:SetPoint("TOPLEFT", 15, -13)
  emblem:SetTexture(AF.ACTIVITY_ICON)
  local mask = drag:CreateMaskTexture()
  mask:SetAllPoints(emblem)
  mask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
  emblem:AddMaskTexture(mask)
  local rim = drag:CreateTexture(nil, "OVERLAY")
  rim:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
  rim:SetSize(90, 90)
  rim:SetPoint("TOPLEFT", 3, -5)
  self.title = line(drag, 76, -10, 404, AF:T("TITLE"), 23, C.gold)
  self.subtitle = line(drag, 77, -38, 404, AF:T("TAGLINE"), 11, C.muted)
  self.subtitle:SetHeight(22)
  self.close = CreateFrame("Button", nil, window, "UIPanelCloseButton")
  self.close:SetPoint("TOPRIGHT", -6, -6)
  self.close:SetScript("OnClick", function() window:Hide() end)
  table.insert(UISpecialFrames, "AzerothFitnessWindow")

  self.tabs, self.pages = {}, {}
  window.minTabWidth, window.maxTabWidth, window.tabPadding = 130, 130, 12
  for i, id in ipairs({ "today", "history", "records", "settings" }) do
    local tab = CreateFrame("Button", nil, window, "PanelTopTabButtonTemplate")
    tab:SetPoint("TOPLEFT", 24 + (i - 1) * 139, -79)
    tab:SetSize(130, 32)
    tab:SetText(AF:T(string.upper(id)))
    tab:SetScript("OnClick", function() UI:Show(id) end)
    function tab:SetLabel(value) self:SetText(value) end
    self.tabs[id] = tab
    local page = CreateFrame("Frame", nil, window)
    page:SetPoint("TOPLEFT", 20, -115)
    page:SetPoint("BOTTOMRIGHT", -20, 20)
    self.pages[id] = page
  end
  self:BuildToday()
  self:BuildHistory()
  self:BuildRecords()
  self:BuildSettings()
  window:SetScript("OnShow", function() UI:Fit() end)
end

function UI:BuildToday()
  local page = self.pages.today
  self.todayLabel = line(page, 12, -4, 380, AF:T("DAILY_ACTIVITY"), 17, C.gold)
  self.todayDate = line(page, 380, -7, 168, "", 12, C.muted)
  self.goals = {}
  for i, entry in ipairs({ { "steps", "STEPS" }, { "jumps", "JUMPS" }, { "murlos", "MURLO" } }) do
    local id, key = entry[1], entry[2]
    local frame = panel(page, 0, -38 - (i - 1) * 102, 560, 94)
    local label = line(frame, 15, -11, 220, AF:T(key), 14, C[id])
    local value = line(frame, 15, -33, 210, "", 26, C.white)
    local target = line(frame, 227, -43, 190, "", 14, C.muted)
    local percent = line(frame, 428, -37, 116, "", 16, C[id])
    percent:SetJustifyH("RIGHT")
    local progress = bar(frame, 14, -64, 532, 18, C[id])
    self.goals[id] = { label = label, value = value, target = target, percent = percent, bar = progress, key = key }
  end
  local details = panel(page, 0, -352, 560, 100)
  self.distanceTitle = line(details, 14, -12, 235, AF:T("DISTANCE"), 12, C.gold)
  self.distance = line(details, 14, -34, 240, "", 23)
  self.detail = line(details, 270, -17, 275, "", 12, C.muted)
  self.detail:SetHeight(68)
  self.accuracy = line(page, 9, -464, 542, "", 11, C.muted)
  self.disclaimer = line(page, 9, -486, 542, AF:T("ESTIMATE"), 11, C.muted)
  self.disclaimer:SetHeight(28)
end

function UI:BuildHistory()
  local page = self.pages.history
  self.week = button(page, AF:T("WEEK"), 0, -4, 126, 26, function() UI.range = 7; UI:Refresh() end)
  self.month = button(page, AF:T("MONTH"), 134, -4, 126, 26, function() UI.range = 30; UI:Refresh() end)
  self.historySummary = line(page, 10, -50, 540, "", 17, C.gold)
  local chart = panel(page, 0, -90, 560, 300)
  self.historyBars = {}
  for i = 1, 30 do
    local b = CreateFrame("Frame", nil, chart)
    b:SetSize(12, 235)
    local fill = b:CreateTexture(nil, "ARTWORK")
    fill:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
    fill:SetVertexColor(unpack(C.steps))
    fill:SetPoint("BOTTOM")
    local label = text(b, "", 10, C.muted, "CENTER")
    label:SetPoint("TOP", b, "BOTTOM", 0, -7)
    b.fill, b.label = fill, label
    self.historyBars[i] = b
  end
  self.historyFootnote = line(page, 10, -409, 540, AF:T("LOCAL_DATE"), 12, C.muted)
  self.historyDates = line(page, 10, -446, 540, "", 13)
end

function UI:BuildRecords()
  local page = self.pages.records
  local summary = panel(page, 0, -4, 560, 116)
  self.best = line(summary, 15, -16, 530, "", 16, C.gold)
  self.streak = line(summary, 15, -51, 530, "", 16, C.steps)
  self.lifetime = line(summary, 15, -86, 530, "", 12, C.muted)
  local awards = panel(page, 0, -132, 560, 360)
  self.achievementTitle = line(awards, 15, -13, 530, AF:T("ACHIEVEMENTS"), 16, C.gold)
  self.awards = {}
  for i = 1, #AF.ACHIEVEMENTS do
    local label = line(awards, 15, -43 - (i - 1) * 44, 530, "", 12, C.muted)
    label:SetHeight(38)
    self.awards[i] = label
  end
end

local function edit(parent, x, y, initial)
  local field = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
  field:SetSize(142, 26)
  field:SetPoint("TOPLEFT", x, y)
  field:SetAutoFocus(false)
  field:SetFontObject("GameFontHighlight")
  field:SetText(initial or "")
  field:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
  field:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
  return field
end

function UI:SaveSettings()
  local stride = tonumber((self.strideInput:GetText():gsub(",", ".")))
  if not stride or stride ~= stride or stride < 0.3 or stride > 5 then
    AF:Say(AF:T("BAD_STRIDE")); return
  end
  local ok, errorKey = AF:SetDailyGoals(tonumber(self.goalInput:GetText()),
    tonumber(self.jumpGoalInput:GetText()), tonumber(self.murloGoalInput:GetText()))
  if not ok then AF:Say(AF:T(errorKey)); return end
  AF.char.stride = stride
  for _, input in ipairs({ self.goalInput, self.jumpGoalInput, self.murloGoalInput, self.strideInput }) do
    input:ClearFocus()
  end
  AF:Say(AF:T("SUCCESS"))
  self:Refresh()
end

function UI:BuildSettings()
  local page = self.pages.settings
  local targets = panel(page, 0, -4, 560, 278)
  self.settingsTitle = line(targets, 15, -14, 520, AF:T("DAILY_GOALS"), 16, C.gold)
  self.goalLabel = line(targets, 16, -53, 345, AF:T("GOAL"), 13)
  self.goalInput = edit(targets, 391, -47)
  self.jumpGoalLabel = line(targets, 16, -94, 345, AF:T("JUMP_GOAL"), 13)
  self.jumpGoalInput = edit(targets, 391, -88)
  self.murloGoalLabel = line(targets, 16, -135, 345, AF:T("MURLO_GOAL"), 13)
  self.murloGoalInput = edit(targets, 391, -129)
  self.strideLabel = line(targets, 16, -176, 345, AF:T("STRIDE"), 13)
  self.strideInput = edit(targets, 391, -170)
  self.save = button(targets, AF:T("SAVE"), 16, -222, 150, 28, function() UI:SaveSettings() end)
  self.savedNote = line(targets, 185, -224, 350, AF:T("GOALS_NOTE"), 11, C.muted)
  self.savedNote:SetHeight(38)

  local options = panel(page, 0, -286, 560, 210)
  self.minimapToggle = CreateFrame("CheckButton", nil, options, "UICheckButtonTemplate")
  self.minimapToggle:SetPoint("TOPLEFT", 11, -14)
  self.minimapLabel = line(options, 45, -22, 490, AF:T("SHOW_MINIMAP"), 13)
  self.minimapToggle:SetScript("OnClick", function(self)
    AF.db.showMinimap = self:GetChecked() and true or false
    UI.mapButton:SetShown(AF.db.showMinimap)
  end)
  self.dateNote = line(options, 16, -68, 525, AF:T("LOCAL_DATE"), 12, C.muted)
  self.estimateNote = line(options, 16, -104, 525, AF:T("ESTIMATE"), 11, C.muted)
  self.estimateNote:SetHeight(32)
end

function UI:Refresh()
  if not self.window or not self.window:IsShown() or not AF.char then return end
  local today, dayKey = AF:Today()
  self.todayDate:SetText(dayKey)
  local targets = { steps = today.goal, jumps = today.activityGoals.jumps, murlos = today.activityGoals.murlos }
  for id, goal in pairs(self.goals) do
    local current, target = today[id], targets[id]
    local value = id == "murlos" and AF:FormatDecimal(current, 1) or AF:FormatNumber(current)
    goal.value:SetText(value)
    goal.target:SetText("/ " .. AF:FormatNumber(target))
    goal.percent:SetText(math.floor(current * 100 / target + 0.000000001) .. "%")
    goal.bar:SetProgress(current / target)
  end
  self.distance:SetText(AF:FormatDistance(AF:FootYards(today)))
  self.detail:SetText(string.format("%s: %s\n%s: %s\n%s: %s",
    AF:T("RUN"), AF:FormatDistance(today.yards.run), AF:T("WALK"), AF:FormatDistance(today.yards.walk),
    AF:T("BACK"), AF:FormatDistance(today.yards.back)))
  local coverage = (today.coverage.position or 0) + (today.coverage.speed or 0)
  self.accuracy:SetText(string.format(AF:T("COVERAGE"),
    coverage > 0 and (today.coverage.position or 0) / coverage * 100 or 0))

  -- Only update the chart/records while their page is selected.
  if self.page == "history" then self:RefreshHistory(today.goal) end
  if self.page == "records" then self:RefreshRecords() end
end

function UI:RefreshHistory(goal)
  local range = self.range or 7
  local total = AF:Aggregate(range)
  self.historySummary:SetText(AF:FormatNumber(total.steps) .. " " .. AF:T("STEPS")
    .. "  |  " .. AF:FormatDistance(AF:FootYards(total)))
  local maximum = math.max(1, goal)
  for offset = 0, range - 1 do
    local day = AF.char.days[AF:DayKey(offset)]
    maximum = math.max(maximum, day and day.steps or 0)
  end
  for i, b in ipairs(self.historyBars) do
    if i <= range then
      local offset = range - i
      local day = AF.char.days[AF:DayKey(offset)]
      local steps = day and day.steps or 0
      local width, gap = range == 7 and 65 or 12, range == 7 and 12 or 5.8
      b:SetWidth(width)
      b:ClearAllPoints()
      b:SetPoint("BOTTOMLEFT", b:GetParent(), "BOTTOMLEFT", 15 + (i - 1) * (width + gap), 35)
      b.fill:SetWidth(width)
      b.fill:SetHeight(math.max(0.1, 235 * steps / maximum))
      b.label:SetText(range == 7 and AF:DayKey(offset):sub(6) or
        ((i == 1 or i == range or i % 5 == 0) and AF:DayKey(offset):sub(9) or ""))
      b:Show()
    else b:Hide() end
  end
  self.historyDates:SetText(AF:DayKey(range - 1) .. " - " .. AF:DayKey())
end

function UI:RefreshRecords()
  local bestKey, steps = AF:BestDay()
  self.best:SetText(AF:T("BEST") .. ": " .. AF:FormatNumber(steps) .. (bestKey and " (" .. bestKey .. ")" or ""))
  self.streak:SetText(AF:T("STREAK") .. ": " .. AF:Streak() .. " " .. AF:T("DAYS"))
  self.lifetime:SetText(AF:T("LIFETIME") .. ": " .. AF:FormatNumber(AF.char.total.steps) .. " " .. AF:T("STEPS")
    .. " | " .. AF:FormatDistance(AF:FootYards(AF.char.total)))
  for i, award in ipairs(AF.ACHIEVEMENTS) do
    local won = AF.char.achievements[award.id]
    local name, description = AF:T("AWARD_" .. award.id), AF:T("AWARD_DESC_" .. award.id)
    self.awards[i]:SetText(name .. "\n" .. description)
    color(self.awards[i], won and C.gold or C.muted)
  end
end

function UI:Show(page)
  self.page = page or self.page or "today"
  if self.page == "settings" then
    self.goalInput:SetText(tostring(AF.char.goal))
    self.jumpGoalInput:SetText(tostring(AF.char.activityGoals.jumps))
    self.murloGoalInput:SetText(tostring(AF.char.activityGoals.murlos))
    self.strideInput:SetText(AF:FormatDecimal(AF:Stride("run"), 2))
    self.minimapToggle:SetChecked(AF.db.showMinimap)
  end
  for id, frame in pairs(self.pages) do
    frame:SetShown(id == self.page)
    if id == self.page then PanelTemplates_SelectTab(self.tabs[id])
    else PanelTemplates_DeselectTab(self.tabs[id]) end
  end
  self.window:Show()
  self:Refresh()
end
function UI:Toggle()
  if self.window:IsShown() then self.window:Hide() else self:Show("today") end
end
function UI:Init()
  self.range = 7
  self:Build()
  self.mapButton = AF.MinimapButton:Init(self)
  C_Timer.NewTicker(1, function()
    if UI.window and UI.window:IsShown() then UI:Refresh() end
  end)
end
