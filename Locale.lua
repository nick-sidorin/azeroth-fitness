local _, AF = ...
local EN = {
  TITLE = "Azeroth Fitness", TODAY = "Today", HISTORY = "History", RECORDS = "Records",
  SETTINGS = "Settings", STEPS = "Steps", JUMPS = "Jumps", MURLO = "Murlocalories",
  TAGLINE = "Adventures count. Your chair agrees.", DAILY_ACTIVITY = "Today's activity",
  DAILY_GOALS = "Daily goals", JUMP_GOAL = "Daily jump goal", MURLO_GOAL = "Daily Murlocalorie goal",
  GOALS_NOTE = "Changes apply to today. Past targets stay saved.", SHOW_MINIMAP = "Show minimap button",
  MINIMAP_HINT = "Left-click: open tracker\nRight-click: settings\nDrag: move around the minimap",
  BAD_JUMP_GOAL = "Jump goal must be from 1 to 100,000.",
  BAD_MURLO_GOAL = "Murlocalorie goal must be from 1 to 100,000.", AWARD_UNLOCKED = "Achievement unlocked: %s",
  DISTANCE = "On foot", RUN = "Running", WALK = "Walking", BACK = "Backpedaling",
  LEFT = "Strafing left", RIGHT = "Strafing right", SWIM = "Swimming", MOUNT = "Mounted",
  UNKNOWN = "Direction unknown", WEEK = "7 days", MONTH = "30 days",
  BEST = "Best day", STREAK = "Goal streak", DAYS = "days", LIFETIME = "Lifetime",
  GOAL = "Daily step goal", STRIDE = "Running stride (yards/step)", SAVE = "Save",
  CLOSE = "Close", ESTIMATE = "Steps are estimated. Murlocalories are fictional.",
  COVERAGE = "Measured by coordinates: %.0f%% of walking distance",
  EMPTY = "No activity recorded yet", UNITS = "yards",
  LOCALE = "Language", LOCAL_DATE = "Days follow your computer's local date.",
  GOAL_DONE = "Daily goal complete!", ACHIEVEMENTS = "Achievements",
  SUCCESS = "Saved", TRANSPORT = "Transport", MOVE = "Moving time",
  FOOT_NOTE = "Foot distances include estimation where coordinates are unavailable.",
  PROBE = "Movement: %s | source: %s",
  HELP = "/af, /af stats, /af settings, /af history, /af debug",
  BAD_GOAL = "Please enter a goal from 100 to 1,000,000.",
  BAD_STRIDE = "Stride must be between 0.3 and 5 yards.",
  MODE_POSITION = "position", MODE_SPEED = "speed estimate", MODE_NONE = "unavailable",
  BAD_CLIENT = "This addon is designed for WoW: Forever (Interface 16001).",
}
local RU = {
  TITLE = "Фитнес Азерота", TODAY = "Сегодня", HISTORY = "История", RECORDS = "Рекорды",
  SETTINGS = "Настройки", STEPS = "Шаги", JUMPS = "Прыжки", MURLO = "Мурлокалории",
  TAGLINE = "Приключения считаются. Кресло одобряет.", DAILY_ACTIVITY = "Активность за сегодня",
  DAILY_GOALS = "Дневные цели", JUMP_GOAL = "Цель прыжков на день", MURLO_GOAL = "Цель мурлокалорий на день",
  GOALS_NOTE = "Изменения действуют сегодня. Прошлые цели сохраняются.", SHOW_MINIMAP = "Кнопка у миникарты",
  MINIMAP_HINT = "ЛКМ — открыть трекер\nПКМ — настройки\nПеретащи — переместить значок",
  BAD_JUMP_GOAL = "Цель прыжков должна быть от 1 до 100 000.",
  BAD_MURLO_GOAL = "Цель мурлокалорий должна быть от 1 до 100 000.", AWARD_UNLOCKED = "Получено достижение: %s",
  DISTANCE = "Пешком", RUN = "Бег", WALK = "Ходьба", BACK = "Задом",
  LEFT = "Боком влево", RIGHT = "Боком вправо", SWIM = "Плавание", MOUNT = "Верхом",
  UNKNOWN = "Направление неизвестно", WEEK = "7 дней", MONTH = "30 дней",
  BEST = "Лучший день", STREAK = "Серия целей", DAYS = "дн.", LIFETIME = "За всё время",
  GOAL = "Цель шагов на день", STRIDE = "Шаг при беге (ярдов/шаг)", SAVE = "Сохранить",
  CLOSE = "Закрыть", ESTIMATE = "Шаги — оценка. Мурлокалории — выдумка.",
  COVERAGE = "По координатам: %.0f%% пешей дистанции",
  EMPTY = "Пока нет активности", UNITS = "ярдов",
  LOCALE = "Язык", LOCAL_DATE = "Дни считаются по местной дате компьютера.",
  GOAL_DONE = "Дневная цель достигнута!", ACHIEVEMENTS = "Достижения",
  SUCCESS = "Сохранено", TRANSPORT = "Транспорт", MOVE = "В движении",
  FOOT_NOTE = "Пешая дистанция иногда оценивается по скорости, когда координаты недоступны.",
  PROBE = "Движение: %s | источник: %s",
  HELP = "/af, /af stats, /af settings, /af history, /af debug",
  BAD_GOAL = "Цель должна быть от 100 до 1 000 000.",
  BAD_STRIDE = "Длина шага: от 0.3 до 5 ярдов.",
  MODE_POSITION = "координаты", MODE_SPEED = "оценка по скорости", MODE_NONE = "нет данных",
  BAD_CLIENT = "Аддон разработан для WoW: Forever (Interface 16001).",
}
local awards = {
  { "touchGrass", "Touch Grass", "10,000 lifetime steps", "Потрогай траву", "10 000 шагов за всё время" },
  { "stillSitting", "Still Sitting", "50,000 steps in one day", "Всё ещё сидишь", "50 000 шагов за один день" },
  { "backpedal", "Backpedal Champion", "1,000 yards backward", "Чемпион заднего хода", "1 000 ярдов задом" },
  { "crabMode", "Crab Mode", "10 km of strafing", "Режим краба", "10 км боком" },
  { "jumpAddict", "Jump Addict", "1,000 jumps", "Прыгун", "1 000 прыжков" },
  { "marathon", "Azeroth Marathon", "42.195 km on foot", "Марафон Азерота", "42,195 км пешком" },
  { "couch", "Professional Couch Adventurer", "7-day goal streak", "Профессиональный диванный герой", "Дневная цель 7 дней подряд" },
}
for _, award in ipairs(awards) do
  EN["AWARD_" .. award[1]], EN["AWARD_DESC_" .. award[1]] = award[2], award[3]
  RU["AWARD_" .. award[1]], RU["AWARD_DESC_" .. award[1]] = award[4], award[5]
end
function AF:T(key)
  local locale = self.db and self.db.language or "auto"
  if locale == "auto" then locale = GetLocale() == "ruRU" and "ru" or "en" end
  local strings = locale == "ru" and RU or EN
  return strings[key] or EN[key] or key
end
