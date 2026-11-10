-- Exercise missing optional artwork without modifying native frame geometry.
for _, available in ipairs({ true, false }) do
  local Mock = assert(loadfile("tests/ui_mock.lua"))()
  if not available then
    Mock.atlases["Profession-Background-Overview"] = nil
    Mock.atlases["Professions-background-summarylist"] = nil
  end
  local AF = { ACTIVITY_ICON = "Interface\\Icons\\Ability_Rogue_Sprint", ACHIEVEMENTS = {}, T = function(_, key) return key end }
  assert(loadfile("Achievements.lua"))("AzerothFitness", AF)
  assert(loadfile("UI.lua"))("AzerothFitness", AF)
  AF.UI:Build()
  local window = AF.UI.window
  assert(window.surface.solid[4] == 1)
  if available then
    assert(window.Bg.atlas == "Profession-Background-Overview" and not window.TopTileStreaks:IsShown())
  else
    assert(window.Bg.texture == "Interface\\FrameGeneral\\UI-Background-Rock" and window.TopTileStreaks:IsShown())
  end
  local count = 0
  for _, frame in ipairs(Mock.objects) do
    if frame.template == "InsetFrameTemplate" then
      count = count + 1
      assert(frame.NineSlice and frame.surface.solid[4] == 1)
      if available then assert(frame.Bg.atlas == "Professions-background-summarylist")
      else assert(frame.Bg.texture == "Interface\\FrameGeneral\\UI-Background-Marble") end
    end
  end
  assert(count > 0)
  UIParent:SetSize(600, 590)
  AF.UI:Fit()
  assert(window.scale * (600 + AF.UI.sideWidth + 20) <= UIParent:GetWidth() * 0.94 + 0.000001)
end
print("PASS: professions artwork and native rock/marble fallback, opaque backing, inset frames and sidebar-aware fitting")
