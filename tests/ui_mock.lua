-- Strict subset of the ordinary UI API. Unknown method calls fail the tests.
local Mock = { objects = {}, tickers = {} }
local Methods = {}
local function object(kind, name, parent, template)
  local result = setmetatable({ kind = kind, name = name, parent = parent, template = template,
    shown = true, scripts = {}, points = {}, width = 0, height = 0, level = 1, scale = 1 }, { __index = Methods })
  Mock.objects[#Mock.objects + 1] = result
  if template == "PortraitFrameTemplate" then
    result.Bg = object("Texture", nil, result)
    result.Bg.texture = "Interface\\FrameGeneral\\UI-Background-Rock"
    result.TopTileStreaks = object("Texture", nil, result)
    result.NineSlice = object("Frame", nil, result)
    result.PortraitContainer = object("Frame", nil, result)
    result.PortraitContainer.portrait = object("Texture", nil, result.PortraitContainer)
    result.TitleContainer = object("Frame", nil, result)
    result.TitleContainer.TitleText = object("FontString", nil, result.TitleContainer)
    result.TitleContainer.TitleText.font = "NativeLocaleFont"
    result.CloseButton = object("Button", nil, result, "UIPanelCloseButtonDefaultAnchors")
    result.CloseButton.scripts.OnClick = function(button)
      if result.onCloseCallback and result.onCloseCallback(button) == false then return end
      result:Hide()
    end
    result.scripts.OnShow = function() result.nativeShowRuns = (result.nativeShowRuns or 0) + 1 end
  elseif template == "InsetFrameTemplate" then
    result.Bg = object("Texture", nil, result)
    result.Bg.texture = "Interface\\FrameGeneral\\UI-Background-Marble"
    result.NineSlice = object("Frame", nil, result)
  elseif template == "LargeSideTabButtonTemplate" then
    local art = C_Texture.GetAtlasInfo("common-sidetab")
    result.width, result.height = art.width, art.height - 5
    result.Icon = object("Texture", nil, result)
    result.SelectedTexture = object("Texture", nil, result)
    result.scripts.OnMouseDown = function() result.pressed = true end
    result.scripts.OnMouseUp = function(frame, button, inside)
      frame.pressed = false
      frame.nativeMouseUpRuns = (frame.nativeMouseUpRuns or 0) + 1
      if frame.customMouseUpHandler then frame.customMouseUpHandler(frame, button, inside) end
    end
  end
  return result
end
function Methods:SetSize(w, h) self.width, self.height = w, h end
function Methods:SetWidth(w) self.width = w end
function Methods:SetHeight(h) self.height = h end
function Methods:GetWidth() return self.width end
function Methods:GetHeight() return self.height end
function Methods:SetPoint(...) self.points[#self.points + 1] = { ... } end
function Methods:ClearAllPoints() self.points = {} end
function Methods:SetAllPoints(target) self.allPoints = target end
function Methods:GetParent() return self.parent end
function Methods:SetScript(event, callback)
  assert(event ~= "OnClick" or self.kind == "Button" or self.kind == "CheckButton", "OnClick requires a button")
  self.scripts[event] = callback
end
function Methods:HookScript(event, callback)
  local previous = self.scripts[event]
  self.scripts[event] = function(...)
    if previous then previous(...) end
    callback(...)
  end
end
function Methods:SetShown(shown) if shown then self:Show() else self:Hide() end end
function Methods:Show()
  local changed = not self.shown
  self.shown = true
  if changed and self.scripts.OnShow then self.scripts.OnShow(self) end
end
function Methods:Hide()
  local changed = self.shown
  self.shown = false
  if changed and self.scripts.OnHide then self.scripts.OnHide(self) end
end
function Methods:IsShown() return self.shown end
function Methods:SetText(value) self.value = value end
function Methods:GetText() return self.value end
function Methods:SetFont(face, size, flags) self.font, self.fontSize, self.fontFlags = face, size, flags end
function Methods:SetFontObject(value) self.fontObject = value end
function Methods:SetTexture(path) self.texture = path; return true end
function Methods:SetAtlas(atlas, useSize)
  local info = assert(C_Texture.GetAtlasInfo(atlas), "Unknown atlas: " .. atlas)
  self.atlas, self.texture = atlas, nil
  if useSize then self:SetSize(info.width, info.height) end
end
function Methods:SetTitle(title) self.TitleContainer.TitleText:SetText(title) end
function Methods:SetPortraitToAsset(texture) self.PortraitContainer.portrait:SetTexture(texture) end
function Methods:SetFillToInterior(fill) self.fillToInterior = fill end
function Methods:SetCustomOnMouseUpHandler(callback) self.customMouseUpHandler = callback end
function Methods:SetColorTexture(...) self.solid = { ... } end
function Methods:SetHorizTile(value) self.horizTile = value end
function Methods:SetVertTile(value) self.vertTile = value end
function Methods:SetTexCoord(...) self.texCoord = { ... } end
function Methods:SetVertexColor(...) self.tint = { ... } end
function Methods:SetTextColor(...) self.tint = { ... } end
function Methods:SetBackdrop(value) self.backdrop = value end
function Methods:SetBackdropColor(...) self.backdropColor = { ... } end
function Methods:SetBackdropBorderColor(...) self.borderColor = { ... } end
function Methods:SetStatusBarTexture(value) self.texture = value end
function Methods:SetStatusBarColor(...) self.tint = { ... } end
function Methods:SetMinMaxValues(minimum, maximum) self.minimum, self.maximum = minimum, maximum end
function Methods:SetValue(value) self.value = value end
function Methods:SetChecked(value)
  self.checked = value
  if self.SelectedTexture then self.SelectedTexture:SetShown(value) end
end
function Methods:GetChecked() return self.checked end
function Methods:SetEnabled(value) self.enabled = value end
function Methods:SetScale(value) self.scale = value end
function Methods:GetEffectiveScale() return self.scale end
function Methods:GetFrameLevel() return self.level end
function Methods:SetFrameLevel(value) self.level = value end
function Methods:SetToplevel(value) self.toplevel = value end
function Methods:GetCenter() return self.centerX, self.centerY end
function Methods:CreateTexture(name, layer) return object("Texture", name, self, layer) end
function Methods:CreateMaskTexture() return object("Mask", nil, self) end
function Methods:AddMaskTexture(mask) self.mask = mask end
function Methods:CreateFontString(name, layer, template) return object("FontString", name, self, template) end
function Methods:ClearFocus() self.focused = false end
function Methods:StartMoving() self.moving = true end
function Methods:StopMovingOrSizing() self.moving = false end
for _, method in ipairs({ "SetJustifyH", "SetFrameStrata", "SetClampedToScreen", "EnableMouse", "SetMovable",
    "RegisterForDrag", "RegisterForClicks", "SetAutoFocus", "SetHighlightTexture", "SetOwner", "AddLine" }) do
  Methods[method] = function() end
end
CreateFrame = object
Mock.atlases = {
  ["common-sidetab"] = { width = 64, height = 71 },
  ["Profession-Background-Overview"] = { width = 750, height = 594 },
  ["Professions-background-summarylist"] = { width = 300, height = 505 },
}
C_Texture = { GetAtlasInfo = function(name) return Mock.atlases[name] end }
GameFontHighlight = { GetFont = function() return "NativeLocaleFont", 12, "" end }
UISpecialFrames = {}
UIParent = object("Frame")
UIParent:SetSize(1920, 1080)
Minimap = object("Frame")
Minimap:SetSize(200, 200)
Minimap.centerX, Minimap.centerY = 100, 100
GameTooltip = object("Tooltip")
C_Timer = { NewTicker = function(_, callback) Mock.tickers[#Mock.tickers + 1] = callback end }
return Mock
