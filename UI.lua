local _, AF = ...
local UI = {}
AF.UI = UI

local W, H = 520, 570
local C = {
  bg = { 0.055, 0.075, 0.10, 0.98 }, panel = { 0.105, 0.135, 0.18, 1 },
  subtle = { 0.18, 0.22, 0.28, 1 }, white = { 0.94, 0.96, 0.98 },
  muted = { 0.56, 0.64, 0.73 }, lime = { 0.60, 0.94, 0.50 },
  cyan = { 0.43, 0.78, 0.98 }, orange = { 1, 0.69, 0.36 },
}
local function color(fs, c) fs:SetTextColor(c[1], c[2], c[3], c[4] or 1) end
local function rect(parent, layer, c)
  local t = parent:CreateTexture(nil, layer or "BACKGROUND")
  t:SetColorTexture(c[1], c[2], c[3], c[4] or 1)
  return t
end
local function text(parent, value, size, c, justify)
  local fs = parent:CreateFontString(nil, "OVERLAY")
  fs:SetFont("Fonts\\FRIZQT__.TTF", size or 13, "")
  fs:SetText(value or "")
  fs:SetJustifyH(justify or "LEFT")
  color(fs, c or C.white)
  return fs
end
local function panel(parent, x, y, w, h)
  local f = CreateFrame("Frame", nil, parent)
  f:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
  f:SetSize(w, h)
  local bg = rect(f, "BACKGROUND", C.panel)
  bg:SetAllPoints()
  return f
end
local function button(parent, label, x, y, w, h, click)
  local b = CreateFrame("Button", nil, parent)
  b:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
  b:SetSize(w, h)
  local bg = rect(b, "BACKGROUND", C.subtle)
  bg:SetAllPoints()
  b:SetNormalFontObject("GameFontNormal")
  local fs = text(b, label, 12, C.white, "CENTER")
  fs:SetAllPoints()
  b:SetScript("OnClick", click)
  b:SetScript("OnEnter", function() bg:SetColorTexture(0.25, 0.34, 0.39, 1) end)
  b:SetScript("OnLeave", function()
    bg:SetColorTexture(C.subtle[1], C.subtle[2], C.subtle[3], 1)
  end)
  function b:SetLabel(v) fs:SetText(v) end
  return b
end
local function line(parent, x, y, w, value, size, tint)
  local label = text(parent, value, size, tint)
  label:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
  label:SetWidth(w)
  return label
end
local function bar(parent, x, y, width, height, fillColor)
  local f = CreateFrame("Frame", nil, parent)
  f:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
  f:SetSize(width, height)
  local background = rect(f, "BACKGROUND", C.subtle)
  background:SetAllPoints()
  local fill = rect(f, "ARTWORK", fillColor)
  fill:SetPoint("TOPLEFT", f, "TOPLEFT")
  fill:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT")
  f.fill = fill
  function f:SetProgress(p)
    fill:SetWidth(math.max(0.1, math.min(1, p or 0) * width))
  end
  return f
end

function UI:Build()
  local window = CreateFrame("Frame", "AzerothFitnessWindow", UIParent)
  window:SetSize(W, H)
  window:SetPoint("CENTER")
  window:SetFrameStrata("DIALOG")
  window:SetClampedToScreen(true)
  window:EnableMouse(true)
  window:SetMovable(true)
  window:RegisterForDrag("LeftButton")
  window:SetScript("OnDragStart", window.StartMoving)
  window:SetScript("OnDragStop", window.StopMovingOrSizing)
  local bg = rect(window, "BACKGROUND", C.bg)
  bg:SetAllPoints()
  local header = rect(window, "BORDER", C.panel)
  header:SetPoint("TOPLEFT")
  header:SetPoint("TOPRIGHT")
  header:SetHeight(58)
  self.title = line(window, 18, -18, 355, AF:T("TITLE"), 19, C.lime)
  self.close = button(window, "X", W - 43, -12, 30, 30, function() window:Hide() end)
  self.tabs = {
    today = button(window, AF:T("TODAY"), 16, -69, 110, 30, function() UI:Show("today") end),
    history = button(window, AF:T("HISTORY"), 135, -69, 110, 30, function() UI:Show("history") end),
    records = button(window, AF:T("RECORDS"), 254, -69, 110, 30, function() UI:Show("records") end),
    settings = button(window, AF:T("SETTINGS"), 373, -69, 129, 30, function() UI:Show("settings") end),
  }
  self.pages = {}
  for _, id in ipairs({ "today", "history", "records", "settings" }) do
    local page = CreateFrame("Frame", nil, window)
    page:SetPoint("TOPLEFT", window, "TOPLEFT", 0, -105)
    page:SetPoint("BOTTOMRIGHT", window)
    self.pages[id] = page
  end
  self:BuildToday()
  self:BuildHistory()
  self:BuildRecords()
  self:BuildSettings()
  self.window = window
  window:Hide()
end

function UI:BuildToday()
  local p = self.pages.today
  local summary = panel(p, 16, -8, 488, 163)
  self.todayLabel = line(summary, 17, -14, 450, AF:T("TODAY"), 12, C.muted)
  self.steps = line(summary, 17, -35, 450, "0", 42, C.white)
  self.stepUnit = line(summary, 18, -91, 150, AF:T("STEPS"), 13, C.muted)
  self.goalText = line(summary, 315, -93, 155, "", 13, C.lime)
  self.progress = bar(summary, 17, -120, 452, 13, C.lime)

  local a = panel(p, 16, -180, 236, 94)
  self.jumpTitle = line(a, 12, -12, 200, AF:T("JUMPS"), 12, C.muted)
  self.jumps = line(a, 12, -34, 200, "0", 28, C.cyan)
  local b = panel(p, 268, -180, 236, 94)
  self.murloTitle = line(b, 12, -12, 205, AF:T("MURLO"), 12, C.muted)
  self.murlos = line(b, 12, -34, 200, "0", 28, C.orange)

  local c = panel(p, 16, -285, 488, 122)
  self.distanceTitle = line(c, 12, -12, 460, AF:T("DISTANCE"), 12, C.muted)
  self.distance = line(c, 12, -33, 455, "", 24, C.white)
  self.detail = line(c, 12, -75, 456, "", 12, C.muted)
  self.accuracy = line(p, 18, -419, 474, "", 11, C.muted)
  self.disclaimer = line(p, 18, -441, 480, AF:T("ESTIMATE"), 11, C.muted)
end

function UI:BuildHistory()
  local p = self.pages.history
  self.week = button(p, AF:T("WEEK"), 16, -8, 110, 31, function() UI.range = 7; UI:Refresh() end)
  self.month = button(p, AF:T("MONTH"), 136, -8, 110, 31, function() UI.range = 30; UI:Refresh() end)
  self.historySummary = line(p, 17, -52, 480, "", 16, C.white)
  self.historyBars = {}
  -- Bars are native textures, no external chart dependency or huge vertex buffers.
  local chart = panel(p, 16, -92, 488, 260)
  for i = 1, 30 do
    local f = CreateFrame("Frame", nil, chart)
    self.historyBars[i] = f
    f:SetWidth(11)
    f:SetHeight(205)
    f:SetPoint("BOTTOMLEFT", chart, "BOTTOMLEFT", 14 + (i - 1) * 15.1, 30)
    local bg = rect(f, "BACKGROUND", C.subtle)
    bg:SetPoint("BOTTOM")
    bg:SetSize(11, 205)
    f.fill = rect(f, "ARTWORK", C.lime)
    f.fill:SetPoint("BOTTOM")
    f.fill:SetWidth(11)
    f.fill:SetHeight(1)
    local label = text(f, "", 9, C.muted, "CENTER")
    label:SetPoint("TOP", f, "BOTTOM", 0, -6)
    f.label = label
  end
  self.historyFootnote = line(p, 18, -365, 478, AF:T("LOCAL_DATE"), 12, C.muted)
  self.historyDates = line(p, 18, -405, 478, "", 12, C.white)
end

function UI:BuildRecords()
  local p = self.pages.records
  local box1 = panel(p, 16, -8, 488, 115)
  self.best = line(box1, 15, -16, 470, "", 16, C.white)
  self.streak = line(box1, 15, -52, 470, "", 16, C.lime)
  self.lifetime = line(box1, 15, -84, 470, "", 12, C.muted)

  local box2 = panel(p, 16, -136, 488, 312)
  self.achievementTitle = line(box2, 15, -12, 452, AF:T("ACHIEVEMENTS"), 14, C.cyan)
  self.awards = {}
  for i = 1, #AF.ACHIEVEMENTS do
    self.awards[i] = line(box2, 15, -39 - (i - 1) * 37, 454, "", 12, C.muted)
  end
end

local function edit(parent, x, y, width, initial)
  local f = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
  f:SetSize(width, 28)
  f:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
  f:SetAutoFocus(false)
  f:SetText(initial or "")
  f:SetFontObject("GameFontHighlight")
  f:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
  return f
end

function UI:BuildSettings()
  local p = self.pages.settings
  local box1 = panel(p, 16, -8, 488, 267)
  self.goalLabel = line(box1, 15, -16, 438, AF:T("GOAL"), 14, C.white)
  self.goalInput = edit(box1, 25, -45, 154, "10000")
  self.strideLabel = line(box1, 15, -95, 438, AF:T("STRIDE"), 14, C.white)
  self.strideInput = edit(box1, 25, -124, 154, "2.30")
  self.save = button(box1, AF:T("SAVE"), 15, -175, 125, 34, function()
    local goal = tonumber(UI.goalInput:GetText())
    local stride = tonumber(UI.strideInput:GetText())
    if not goal or goal < 100 or goal > 1000000 then
      AF:Say(AF:T("BAD_GOAL")); return
    end
    if not stride or stride < 0.3 or stride > 5 then
      AF:Say(AF:T("BAD_STRIDE")); return
    end
    AF.char.goal, AF.char.stride = math.floor(goal), stride
    -- Existing days retain the goal frozen on that day; today's goal changes.
    AF:Today().goal = AF.char.goal
    AF:Say(AF:T("SUCCESS"))
    UI:Refresh()
  end)
  self.savedNote = line(box1, 15, -225, 440, AF:T("ESTIMATE"), 11, C.muted)

  local box2 = panel(p, 16, -289, 488, 156)
  self.languageLabel = line(box2, 15, -16, 450, AF:T("LOCALE"), 13, C.white)
  self.languageButtons = {}
  for i, entry in ipairs({ { "Auto", "auto" }, { "English", "en" }, { "Русский", "ru" } }) do
    self.languageButtons[i] = button(box2, entry[1], 15 + (i - 1) * 150, -43, 137, 31, function()
      AF.db.language = entry[2]
      UI:Relocalize()
      UI:Refresh()
    end)
  end
  self.dateNote = line(box2, 15, -102, 455, AF:T("LOCAL_DATE"), 11, C.muted)
end

function UI:Relocalize()
  self.title:SetText(AF:T("TITLE"))
  for id, b in pairs(self.tabs) do b:SetLabel(AF:T(string.upper(id))) end
  self.todayLabel:SetText(AF:T("TODAY"))
  self.stepUnit:SetText(AF:T("STEPS"))
  self.jumpTitle:SetText(AF:T("JUMPS"))
  self.murloTitle:SetText(AF:T("MURLO"))
  self.distanceTitle:SetText(AF:T("DISTANCE"))
  self.disclaimer:SetText(AF:T("ESTIMATE"))
  self.week:SetLabel(AF:T("WEEK"))
  self.month:SetLabel(AF:T("MONTH"))
  self.historyFootnote:SetText(AF:T("LOCAL_DATE"))
  self.achievementTitle:SetText(AF:T("ACHIEVEMENTS"))
  self.goalLabel:SetText(AF:T("GOAL"))
  self.strideLabel:SetText(AF:T("STRIDE"))
  self.save:SetLabel(AF:T("SAVE"))
  self.savedNote:SetText(AF:T("ESTIMATE"))
  self.languageLabel:SetText(AF:T("LOCALE"))
  self.dateNote:SetText(AF:T("LOCAL_DATE"))
end

function UI:Refresh()
  if not self.window or not self.window:IsShown() then return end
  local today = AF:Today()
  local goal = today.goal or AF.char.goal
  self.steps:SetText(AF:FormatNumber(today.steps))
  self.goalText:SetText(AF:FormatNumber(goal) .. "  /  " .. math.floor(today.steps / goal * 100) .. "%")
  self.progress:SetProgress(today.steps / goal)
  self.jumps:SetText(AF:FormatNumber(today.jumps))
  self.murlos:SetText(string.format("%.1f", today.murlos))
  self.distance:SetText(AF:FormatDistance(AF:FootYards(today)))
  self.detail:SetText(string.format("%s: %s  |  %s: %s",
    AF:T("RUN"), AF:FormatDistance(today.yards.run),
    AF:T("WALK"), AF:FormatDistance(today.yards.walk)))
  local total = (today.coverage.position or 0) + (today.coverage.speed or 0)
  self.accuracy:SetText(string.format(AF:T("COVERAGE"),
    total > 0 and (today.coverage.position or 0) / total * 100 or 0))

  local range = self.range or 7
  local aggregate = AF:Aggregate(range)
  self.historySummary:SetText(AF:FormatNumber(aggregate.steps) .. " " .. AF:T("STEPS")
    .. "   •   " .. AF:FormatDistance(AF:FootYards(aggregate)))
  local maximum = math.max(1, goal)
  for i = 0, range - 1 do
    local day = AF.char.days[AF:DayKey(i)]
    maximum = math.max(maximum, day and day.steps or 0)
  end
  for i = 1, 30 do
    local b = self.historyBars[i]
    local offset = range - i
    if i <= range then
      local day = AF.char.days[AF:DayKey(offset)]
      local steps = day and day.steps or 0
      local width = range == 7 and 60 or 11
      local gap = range == 7 and 8 or 4.1
      b:SetWidth(width)
      b:SetPoint("BOTTOMLEFT", b:GetParent(), "BOTTOMLEFT", 14 + (i - 1) * (width + gap), 30)
      b.fill:SetWidth(width)
      b.fill:SetHeight(math.max(0.5, 205 * steps / maximum))
      b.label:SetText(range == 7 and AF:DayKey(offset):sub(6) or
        ((i == 1 or i == range or i % 5 == 0) and AF:DayKey(offset):sub(9) or ""))
      b:Show()
    else
      b:Hide()
    end
  end
  self.historyDates:SetText(AF:DayKey(range - 1) .. " — " .. AF:DayKey())

  local bestKey, bestSteps = AF:BestDay()
  self.best:SetText(AF:T("BEST") .. ": " .. AF:FormatNumber(bestSteps)
    .. (bestKey and "  (" .. bestKey .. ")" or ""))
  self.streak:SetText(AF:T("STREAK") .. ": " .. AF:Streak() .. " " .. AF:T("DAYS"))
  self.lifetime:SetText(AF:T("LIFETIME") .. ": " .. AF:FormatNumber(AF.char.total.steps)
    .. " " .. AF:T("STEPS") .. " • " .. AF:FormatDistance(AF:FootYards(AF.char.total)))
  for i, a in ipairs(AF.ACHIEVEMENTS) do
    local won = AF.char.achievements[a.id]
    local fs = self.awards[i]
    fs:SetText((won and "✓  " or "○  ") .. a.name .. " — " .. a.desc)
    color(fs, won and C.lime or C.muted)
  end
end

function UI:Show(page)
  self.page = page or self.page or "today"
  if self.page == "settings" then
    self.goalInput:SetText(tostring(AF.char.goal))
    self.strideInput:SetText(string.format("%.2f", AF:Stride("run")))
  end
  for id, frame in pairs(self.pages) do
    if id == self.page then frame:Show() else frame:Hide() end
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
  local mapButton = CreateFrame("Button", "AzerothFitnessMinimapButton", Minimap)
  mapButton:SetSize(27, 27)
  mapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -8, -10)
  mapButton:SetNormalTexture("Interface\\Icons\\INV_Misc_Rune_01")
  mapButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
  mapButton:RegisterForClicks("LeftButtonUp")
  mapButton:SetScript("OnClick", function() UI:Toggle() end)
  mapButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText("Azeroth Fitness")
    GameTooltip:AddLine(AF:T("HELP"), 1, 1, 1)
    GameTooltip:Show()
  end)
  mapButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
  mapButton:SetShown(AF.db.showMinimap)
  self.mapButton = mapButton
  -- Redraw only visible views once a second; movement accounting is independent.
  C_Timer.NewTicker(1, function()
    if UI.window and UI.window:IsShown() then UI:Refresh() end
  end)
end
