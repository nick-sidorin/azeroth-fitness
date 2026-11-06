local _, AF = ...
local EN = {
  TITLE = "AZEROTH FITNESS", TODAY = "TODAY", HISTORY = "HISTORY", RECORDS = "RECORDS",
  SETTINGS = "SETTINGS", STEPS = "steps", JUMPS = "jumps", MURLO = "Murlocalories",
  DISTANCE = "On foot", RUN = "Running", WALK = "Walking", BACK = "Backpedaling",
  LEFT = "Strafing left", RIGHT = "Strafing right", SWIM = "Swimming", MOUNT = "Mounted",
  UNKNOWN = "Direction unknown", WEEK = "7 days", MONTH = "30 days",
  BEST = "Best day", STREAK = "Goal streak", DAYS = "days", LIFETIME = "Lifetime",
  GOAL = "Daily step goal", STRIDE = "Running stride (yards/step)", SAVE = "Save",
  CLOSE = "Close", ESTIMATE = "Steps and Murlocalories are estimates, not physical measurements.",
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
  TITLE = "ФИТНЕС АЗЕРОТА", TODAY = "СЕГОДНЯ", HISTORY = "ИСТОРИЯ", RECORDS = "РЕКОРДЫ",
  SETTINGS = "НАСТРОЙКИ", STEPS = "шагов", JUMPS = "прыжков", MURLO = "Мурлокалории",
  DISTANCE = "Пешком", RUN = "Бег", WALK = "Ходьба", BACK = "Задом",
  LEFT = "Боком влево", RIGHT = "Боком вправо", SWIM = "Плавание", MOUNT = "Верхом",
  UNKNOWN = "Направление неизвестно", WEEK = "7 дней", MONTH = "30 дней",
  BEST = "Лучший день", STREAK = "Серия целей", DAYS = "дн.", LIFETIME = "За всё время",
  GOAL = "Цель шагов на день", STRIDE = "Шаг при беге (ярдов/шаг)", SAVE = "Сохранить",
  CLOSE = "Закрыть", ESTIMATE = "Шаги и мурлокалории — условные оценки, а не физические измерения.",
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
function AF:T(key)
  local locale = self.db and self.db.language or "auto"
  if locale == "auto" then locale = GetLocale() == "ruRU" and "ru" or "en" end
  local strings = locale == "ru" and RU or EN
  return strings[key] or EN[key] or key
end
