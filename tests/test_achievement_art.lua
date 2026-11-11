-- Atlas UVs and authored subframe geometry prevent cropped shields and misplaced icons.
for _, available in ipairs({ true, false }) do
  local Mock = assert(loadfile("tests/ui_mock.lua"))()
  local atlasUV = { 0.25, 0.4, 0.6, 0.8 }
  if available then
    Mock.atlases["ui-achievement-iconframe"] = { width = 72, height = 72, texCoord = atlasUV }
    Mock.atlases["ui-achievement-shield-1"] = { width = 66, height = 64, texCoord = atlasUV }
    Mock.atlases["ui-achievement-alert-background"] = { width = 330, height = 96, texCoord = atlasUV }
  else
    Mock.atlases["Professions-background-summarylist"] = nil
  end
  date, time = os.date, os.time
  GetLocale = function() return "ruRU" end
  UnitGUID = function() return "Art-Test" end
  UnitName = function() return "Test" end
  UnitRace = function() return "Human", "Human" end
  AzerothFitnessDB = nil
  local AF = {}
  for _, file in ipairs({ "Locale.lua", "Core.lua", "Achievements.lua", "Minimap.lua", "UI.lua" }) do
    assert(loadfile(file))("AzerothFitness", AF)
  end
  AF:Init(); AF:Login(); AF.UI:Init()
  local A = AF.Achievements
  A:Refresh(); A:BuildToast()
  -- Inspect rendered atlas regions without depending on controller field names.
  if available then
    for _, region in ipairs(Mock.objects) do
      if region.atlas == "ui-achievement-shield-1" or region.atlas == "ui-achievement-iconframe" then
        assert(region.texCoord == atlasUV and region.resetTexCoords,
          "Achievement atlas regions must discard file-sheet UVs")
      end
    end
  end
  local row, toast = A.rows[1], A.toast
  assert(A.pointsBar.kind == "StatusBar" and A.pointsBar.maximum == 80 and A.pointsBar.value == 0)
  assert(A.heading:GetParent() == A.pointsBar and A.heading.justifyV == "MIDDLE")
  assert(row.template == "BackdropTemplate" and A.listFrame.template == "InsetFrameTemplate")
  assert(A.scroll:GetParent() == A.listFrame and A.scrollbar:GetParent() == A.listFrame)
  assert(row.icon:GetParent() == row.iconFrame:GetParent())
  assert(row.icon.points[1][4] == 0 and row.icon.points[1][5] == 3)
  assert(row.iconFrame.points[1][4] == -1 and row.iconFrame.points[1][5] == 2)
  assert(toast.iconHolder.width == 78 and toast.iconHolder.height == 75)
  assert(toast.iconHolder.points[1][4] == -4 and toast.iconHolder.points[1][5] == -15)
  assert(toast.shieldHolder.points[1][4] == -8 and toast.shieldHolder.points[1][5] == -15)
  assert(toast.scoreText:GetParent() == toast.shieldHolder)
  assert(toast.scoreText.allPoints == toast.shield and row.scoreText.allPoints == row.shield)
  assert(toast.scoreText.justifyH == "CENTER" and toast.scoreText.justifyV == "MIDDLE")
  for _, value in ipairs({ "1", "10", "20", "100" }) do
    toast.scoreText:SetText(value)
    assert(toast.scoreText.allPoints == toast.shield and toast.scoreText.width == toast.shield.width)
  end
  assert(toast.awardName.height == 36 and toast.awardName.justifyV == "MIDDLE" and toast.awardName.maxLines == 2)
  assert(toast.iconFrame.template == "OVERLAY", "The native icon border must render above the icon")
  if available then
    for _, image in ipairs({ toast.background, toast.iconFrame, toast.shield, row.iconFrame, row.shield }) do
      assert(image.atlas and image.texCoord == atlasUV and image.resetTexCoords,
        "Atlas artwork must reset file-sheet UVs, never reuse the old quarter-sheet crop")
      local info = C_Texture.GetAtlasInfo(image.atlas)
      assert(image.width == info.width and image.height == info.height, "Keep authored atlas dimensions")
    end
    assert(AF.UI.tabs.achievements.Icon.atlas == "ui-achievement-shield-1")
    assert(not toast.fallback)
  else
    assert(toast.fallback.template == "InsetFrameTemplate")
    assert(toast.shield.texture:find("UI-Achievement-Shields", 1, true) and toast.shield.texCoord[2] == 0.5)
    assert(row.background.texture == "Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal-Desaturated")
    assert(AF.UI.tabs.achievements.Icon.texture == AF.ACHIEVEMENT_ICON)
  end
  assert(row.background.texture == "Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal-Desaturated",
    "Locked cards need real parchment rather than a nearly flat tall-pane atlas")
  assert(row.background.texCoord[3] == 1 - 96 / 256 and row.background.width == 516)
  assert(row.surface.solid[4] == 1 and row.shade.solid[4] <= 0.55,
    "Keep the card opaque without hiding its texture under a solid overlay")
  assert(row.title.justifyH == "LEFT" and row.description.justifyH == "LEFT" and row.date.justifyH == "LEFT")
  assert(row.backdrop.edgeFile == "Interface\\Tooltips\\UI-Tooltip-Border")
  assert(A.pointsTrack.texture == "Interface\\TargetingFrame\\UI-StatusBar")
  AF.char.achievements.firstSteps = AF:DayKey(); A:Refresh()
  assert(row.background.texture == "Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal")
  assert(row.shade.solid[4] == 0.4 and row.borderColor[1] > A.rows[2].borderColor[1])
  assert(A.pointsBar.value == 10 and A.pointsBar.maximum == 80)
  assert(row.description.tint[1] == 1 and row.title.tint[1] == 1 and row.description.shadowColor[4] == 1,
    "Earned copy must be white with a readable shadow")
  assert(A.rows[2].description.tint[1] < 1 and A.rows[2].icon.desaturated)
end
print("PASS: native atlas UV reset/fallback, authored icon/shield geometry, white earned text and framed point/list/card surfaces")
