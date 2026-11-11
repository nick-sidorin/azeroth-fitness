local _, AF = ...
AF.VERSION = "0.1.0"
AF.SCHEMA = 1
AF.METERS_PER_YARD = 0.9144
AF.MODES = { "run", "walk", "back", "strafeLeft", "strafeRight", "unknown", "swim", "mount", "transport" }
AF.FOOT = { run = true, walk = true, back = true, strafeLeft = true, strafeRight = true, unknown = true }

-- Entirely fictional, intentionally consistent "Murlocalories" per 100 yards and per jump.
AF.MURLO_PER_100Y = { run = 1.8, walk = 1.2, back = 2.2, strafeLeft = 2.4,
  strafeRight = 2.4, unknown = 1.8, swim = 2.0 }
AF.MURLO_JUMP = 0.75
AF.DEFAULT_ACTIVITY_GOALS = { jumps = 100, murlos = 300 }

-- Deliberately coarse race defaults, NOT measured animation footfalls.
-- Per-character calibration in Settings overrides these estimates.
AF.STRIDE_YARDS = { HUMAN = 2.30, DWARF = 2.25, NIGHTELF = 2.30,
  GNOME = 1.80, ORC = 2.35, SCOURGE = 2.25, TAUREN = 3.00,
  TROLL = 2.50, SKYBORNE = 2.30 }

local floor, max = math.floor, math.max
local function readable(x)
  return x ~= nil and not (issecretvalue and issecretvalue(x))
end

function AF:NewLedger()
  return { steps = 0, jumps = 0, murlos = 0, yards = {}, moveSeconds = 0,
    coverage = { position = 0, speed = 0 } }
end

function AF:DayKey(offset)
  if not offset or offset == 0 then return date("%Y-%m-%d") end
  -- Local noon avoids most DST midnight issues for 7/30-day history navigation.
  local t = date("*t")
  t.hour, t.min, t.sec = 12, 0, 0
  return date("%Y-%m-%d", time(t) - offset * 86400)
end

function AF:Today()
  local key = self:DayKey()
  local day = self.char.days[key]
  if not day then
    day = self:NewLedger()
    day.goal = self.char.goal
    day.activityGoals = { jumps = self.char.activityGoals.jumps, murlos = self.char.activityGoals.murlos }
    self.char.days[key] = day
  end
  return day, key
end

function AF:SetDailyGoals(steps, jumps, murlos)
  local function valid(value, minimum, maximum)
    return type(value) == "number" and value == value and value >= minimum and value <= maximum
  end
  if not valid(steps, 100, 1000000) then return false, "BAD_GOAL" end
  if not valid(jumps, 1, 100000) then return false, "BAD_JUMP_GOAL" end
  if not valid(murlos, 1, 100000) then return false, "BAD_MURLO_GOAL" end
  self.char.goal = math.floor(steps)
  self.char.activityGoals = { jumps = math.floor(jumps), murlos = math.floor(murlos) }
  local day = self:Today()
  day.goal = self.char.goal
  day.activityGoals = { jumps = self.char.activityGoals.jumps, murlos = self.char.activityGoals.murlos }
  return true
end

function AF:Stride(gait)
  local base = self.char.stride
  if not base then
    local _, race = UnitRace("player")
    if readable(race) then base = self.STRIDE_YARDS[string.upper(race)] end
  end
  base = base or 2.30
  if gait == "walk" then return base * 0.55 end
  if gait == "back" then return base * 0.68 end
  return base
end

local function addYards(ledger, mode, yards, seconds, source, steps, murlos)
  ledger.yards[mode] = (ledger.yards[mode] or 0) + yards
  ledger.steps = ledger.steps + steps
  ledger.murlos = ledger.murlos + murlos
  ledger.moveSeconds = ledger.moveSeconds + seconds
  if AF.FOOT[mode] and (source == "position" or source == "speed") then
    ledger.coverage[source] = (ledger.coverage[source] or 0) + yards
  end
end

function AF:RecordTravel(mode, yards, seconds, source, strideGait)
  if not self.char or yards <= 0 then return end
  local steps = 0
  if self.FOOT[mode] then
    steps = yards / self:Stride(strideGait or mode)
  end
  local murlos = yards / 100 * (self.MURLO_PER_100Y[mode] or 0)
  local day = self:Today()
  local wasComplete = day.steps >= day.goal
  addYards(day, mode, yards, seconds, source, steps, murlos)
  addYards(self.char.total, mode, yards, seconds, source, steps, murlos)
  if not wasComplete and day.steps >= day.goal then
    self:Say(self:T("GOAL_DONE"))
  end
  self:CheckAchievements()
end

function AF:RecordJump()
  if not self.char then return end
  local day = self:Today()
  day.jumps = day.jumps + 1
  day.murlos = day.murlos + self.MURLO_JUMP
  self.char.total.jumps = self.char.total.jumps + 1
  self.char.total.murlos = self.char.total.murlos + self.MURLO_JUMP
  self:CheckAchievements()
end

function AF:FootYards(ledger)
  local sum = 0
  if not ledger then return 0 end
  for mode in pairs(self.FOOT) do sum = sum + (ledger.yards[mode] or 0) end
  return sum
end

function AF:Streak()
  if not self.char then return 0 end
  local count, start = 0, 0
  local today = self.char.days[self:DayKey()]
  if not today or today.steps < today.goal then start = 1 end
  for i = start, 3650 do
    local day = self.char.days[self:DayKey(i)]
    if not day or day.steps < (day.goal or self.char.goal) then break end
    count = count + 1
  end
  return count
end

function AF:BestDay()
  local bestKey, bestSteps = nil, 0
  for key, day in pairs(self.char.days) do
    if day.steps > bestSteps then bestKey, bestSteps = key, day.steps end
  end
  return bestKey, bestSteps
end

function AF:Aggregate(lastDays)
  local result = self:NewLedger()
  for i = 0, lastDays - 1 do
    local day = self.char.days[self:DayKey(i)]
    if day then
      result.steps = result.steps + day.steps
      result.jumps = result.jumps + day.jumps
      result.murlos = result.murlos + day.murlos
      result.moveSeconds = result.moveSeconds + day.moveSeconds
      for mode, yards in pairs(day.yards) do
        result.yards[mode] = (result.yards[mode] or 0) + yards
      end
    end
  end
  return result
end

-- The same progress getter/target drives both unlocking and the visible meter.
AF.ACHIEVEMENTS = {
  { id = "firstSteps", target = 50, progress = function(a) return a.char.total.steps end },
  { id = "touchGrass", target = 10000, progress = function(a) return a.char.total.steps end },
  { id = "stillSitting", target = 50000, progress = function(a) local _, n = a:BestDay(); return n end },
  { id = "backpedal", target = 1000, unit = "YARDS", progress = function(a) return a.char.total.yards.back or 0 end },
  { id = "crabMode", target = 10000, unit = "METERS", progress = function(a)
      local y = (a.char.total.yards.strafeLeft or 0) + (a.char.total.yards.strafeRight or 0)
      return y * a.METERS_PER_YARD
    end },
  { id = "jumpAddict", target = 1000, progress = function(a) return a.char.total.jumps end },
  { id = "marathon", target = 42195, unit = "METERS", progress = function(a) return a:FootYards(a.char.total) * a.METERS_PER_YARD end },
  { id = "couch", target = 7, progress = function(a) return a:Streak() end },
}

local awardIcons = {
  firstSteps = "Ability_Rogue_Sprint", touchGrass = "INV_Misc_Herb_01",
  stillSitting = "INV_Misc_Book_09", backpedal = "Ability_Rogue_Feint",
  crabMode = "INV_Misc_Fish_14", jumpAddict = "Ability_Kick",
  marathon = "Achievement_Explore_EasternKingdoms", couch = "Achievement_Level_10",
}
for _, award in ipairs(AF.ACHIEVEMENTS) do
  award.points = 10
  award.icon = "Interface\\Icons\\" .. awardIcons[award.id]
end
AF.ACHIEVEMENT_ICON = "Interface\\Icons\\Achievement_PVP_A_01"

function AF:GetAchievementProgress(award)
  local current = self.char and award.progress(self) or 0
  -- Earned awards remain complete even when a current streak later expires.
  if self.char and self.char.achievements[award.id] then current = award.target end
  return math.max(0, math.min(award.target, current)), award.target, award.unit
end

function AF:FormatAchievementProgress(award)
  local current, target, unit = self:GetAchievementProgress(award)
  local counter = self:FormatNumber(math.floor(current)) .. " / " .. self:FormatNumber(target)
  return unit and counter .. " " .. self:T(unit) or counter
end

function AF:GetAchievementList()
  local result = {}
  for index, award in ipairs(self.ACHIEVEMENTS) do
    local earned = self.char and self.char.achievements[award.id]
    result[#result + 1] = { award = award, earned = not not earned, date = earned, order = index }
  end
  table.sort(result, function(a, b)
    if a.earned ~= b.earned then return a.earned end
    return a.order < b.order
  end)
  return result
end

function AF:GetAchievementPoints()
  local earned, available = 0, 0
  for _, award in ipairs(self.ACHIEVEMENTS) do
    available = available + award.points
    if self.char and self.char.achievements[award.id] then earned = earned + award.points end
  end
  return earned, available
end

function AF:CheckAchievements()
  if not self.char then return end
  self.char.achievements = self.char.achievements or {}
  for _, award in ipairs(self.ACHIEVEMENTS) do
    if not self.char.achievements[award.id] and award.progress(self) >= award.target then
      self.char.achievements[award.id] = self:DayKey()
      self:Say(string.format(self:T("AWARD_UNLOCKED"), self:T("AWARD_" .. award.id)))
      if self.Achievements then self.Achievements:Earned(award) end
    end
  end
end

-- Temporary character-only testing reset. The slash entry requests confirmation.
function AF:ResetStatistics()
  if not self.char then return end
  self.char.days, self.char.total, self.char.achievements = {}, self:NewLedger(), {}
  self:Today()
  if self.Motion and self.Motion.Reset then self.Motion.Reset() end
  if self.Jump and self.Jump.Reset then self.Jump.Reset() end
  if self.Achievements then self.Achievements:Clear() end
  if self.UI then self.UI:Refresh() end
end

function AF:Say(message)
  print("|cff90edbaAzeroth Fitness|r " .. message)
end

function AF:FormatNumber(n)
  local s = tostring(floor((n or 0) + 0.5))
  local sign, body = s:match("^(%-?)(%d+)$")
  local separator = self:GetNumberSeparators()
  local grouped = body:reverse():gsub("(%d%d%d)", "%1~"):reverse():gsub("^~", "")
  return sign .. grouped:gsub("~", separator)
end

function AF:FormatDecimal(value, places)
  local _, decimal = self:GetNumberSeparators()
  local formatted = string.format("%." .. places .. "f", value)
  return (formatted:gsub("%.", decimal))
end

function AF:FormatDistance(yards)
  local meters = (yards or 0) * self.METERS_PER_YARD
  if meters < 1000 then return self:FormatNumber(meters) .. " " .. self:T("METERS") end
  return self:FormatDecimal(meters / 1000, 2) .. " " .. self:T("KILOMETERS")
end

function AF:Init()
  AzerothFitnessDB = AzerothFitnessDB or {}
  local db = AzerothFitnessDB
  db.schema = db.schema or self.SCHEMA
  db.characters = db.characters or {}
  db.showMinimap = db.showMinimap ~= false
  self.db = db
end

function AF:Login()
  local guid = UnitGUID("player")
  if not readable(guid) then return end
  local char = self.db.characters[guid]
  if not char then
    char = { name = UnitName("player"), goal = 10000, stride = nil,
      days = {}, total = self:NewLedger(), achievements = {} }
    self.db.characters[guid] = char
  end
  char.days = char.days or {}
  char.goal = char.goal or 10000
  if type(char.activityGoals) ~= "table" then char.activityGoals = {} end
  for key, default in pairs(self.DEFAULT_ACTIVITY_GOALS) do
    local value = char.activityGoals[key]
    if type(value) ~= "number" or value ~= value or value < 1 or value > 100000 then
      char.activityGoals[key] = default
    end
  end
  char.total = char.total or self:NewLedger()
  char.total.yards = char.total.yards or {}
  char.total.coverage = char.total.coverage or { position = 0, speed = 0 }
  for _, day in pairs(char.days) do
    day.yards = day.yards or {}
    day.coverage = day.coverage or { position = 0, speed = 0 }
    day.goal = day.goal or char.goal
  end
  char.achievements = char.achievements or {}
  self.char = char
  local today = self:Today()
  -- Introduce additional targets for today only; do not invent historical goals.
  if type(today.activityGoals) ~= "table" then today.activityGoals = {} end
  for key, default in pairs(char.activityGoals) do
    local value = today.activityGoals[key]
    if type(value) ~= "number" or value ~= value or value < 1 or value > 100000 then
      today.activityGoals[key] = default
    end
  end
end
