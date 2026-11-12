local _, AF = ...
local Rings = {}
AF.Rings = Rings
local MASK = "Interface\\CHARACTERFRAME\\TempPortraitAlphaMask"

function Rings:IsSupported(parent)
  local probe = parent:CreateTexture(nil, "BACKGROUND")
  probe:Hide()
  return type(parent.CreateMaskTexture) == "function" and type(probe.AddMaskTexture) == "function"
    and type(probe.SetRotation) == "function" and type(probe.SetRadialProgressBarPercent) == "function"
end

local function circle(parent, diameter, tint, layer, sublevel)
  local texture = parent:CreateTexture(nil, layer, nil, sublevel)
  texture:SetSize(diameter, diameter); texture:SetPoint("CENTER")
  texture:SetColorTexture(tint[1], tint[2], tint[3], 1)
  local mask = parent:CreateMaskTexture()
  mask:SetAllPoints(texture)
  mask:SetTexture(MASK, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
  texture:AddMaskTexture(mask)
  return texture
end

function Rings:Create(parent, diameter, thickness, tint, background)
  local ring = CreateFrame("Frame", nil, parent)
  ring:SetSize(diameter, diameter)
  ring.track = circle(ring, diameter, { tint[1] * 0.18, tint[2] * 0.18, tint[3] * 0.18 }, "BACKGROUND", 0)
  ring.fill = circle(ring, diameter, tint, "ARTWORK", 0)
  -- The documented default start is at the bottom; rotate the fill to twelve o'clock.
  ring.fill:SetRotation(math.pi)
  if ring.fill.SetRadialProgressBarReverse then ring.fill:SetRadialProgressBarReverse(false) end
  ring.hole = circle(ring, diameter - thickness * 2, background, "ARTWORK", 1)
  ring.startCap = circle(ring, thickness, tint, "ARTWORK", 2)
  ring.endCap = circle(ring, thickness, tint, "ARTWORK", 2)
  local radius = (diameter - thickness) / 2
  ring.startCap:ClearAllPoints(); ring.startCap:SetPoint("CENTER", ring, "CENTER", 0, radius)
  function ring:SetProgress(value)
    value = math.max(0, math.min(1, value or 0))
    if self.value == value then return end
    self.value = value
    self.fill:SetRadialProgressBarPercent(value)
    self.fill:SetShown(value > 0)
    self.startCap:SetShown(value > 0 and value < 1)
    self.endCap:SetShown(value > 0 and value < 1)
    self.endCap:ClearAllPoints()
    self.endCap:SetPoint("CENTER", self, "CENTER", math.sin(value * math.pi * 2) * radius,
      math.cos(value * math.pi * 2) * radius)
  end
  function ring:GetProgress() return self.value end
  ring:SetProgress(0)
  return ring
end
