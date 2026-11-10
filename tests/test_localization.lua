local locales = { "enUS", "enGB", "ruRU", "deDE", "frFR", "esES", "esMX", "itIT", "ptBR", "koKR", "zhCN", "zhTW" }
local function loadLocale(locale)
  GetLocale = function() return locale end
  local AF = { db = { language = "ru" } }
  assert(loadfile("Locale.lua"))("AzerothFitness", AF)
  assert(loadfile("LocaleTranslations.lua"))("AzerothFitness", AF)
  assert(loadfile("Core.lua"))("AzerothFitness", AF)
  return AF
end
-- Capture only format specifiers; literal words do not affect format compatibility.
local function placeholders(value)
  local found = {}
  value = value:gsub("%%%%", "")
  for placeholder in value:gmatch("%%[-+ #0%d%.]*[a-zA-Z]") do found[#found + 1] = placeholder end
  return table.concat(found, ",")
end
for _, locale in ipairs(locales) do
  local AF = loadLocale(locale)
  local dictionary = assert(AF.locales[locale], locale)
  assert(AF:T("TITLE") == "Azeroth Fitness", locale .. ": brand must not be translated")
  for key, english in pairs(AF.locales.enUS) do
    assert(type(dictionary[key]) == "string" and dictionary[key] ~= "", locale .. ": missing " .. key)
    assert(placeholders(dictionary[key]) == placeholders(english), locale .. ": incompatible format " .. key)
    assert(AF:T(key) == dictionary[key], locale .. ": unexpected fallback " .. key)
  end
  assert(AF:T("NOT_A_TRANSLATION") == "NOT_A_TRANSLATION")
  assert(AF:T("HELP"):find("/af", 1, true))
  assert(string.format(AF:T("COVERAGE"), 75):find("75", 1, true))
  assert(string.format(AF:T("PROBE"), "foot", "position"))
  local separator, decimal = AF:GetNumberSeparators()
  assert(AF:FormatNumber(12345) == "12" .. separator .. "345")
  assert(AF:FormatDecimal(12.5, 1) == "12" .. decimal .. "5")
  assert(AF:FormatDistance(1):find(AF:T("METERS"), 1, true))
  dictionary.PROBE = nil
  if dictionary ~= AF.locales.enUS then assert(AF:T("PROBE") == AF.locales.enUS.PROBE) end
end
local unknown = loadLocale("unknown")
assert(unknown:T("TODAY") == "Today")
GetLocale = nil
local missing = {}
assert(loadfile("Locale.lua"))("AzerothFitness", missing)
assert(missing:T("TODAY") == "Today")
print("PASS: all 12 official client locales, complete dictionaries, format placeholders, brand, locale selection, units and fallback")
