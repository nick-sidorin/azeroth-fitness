# Forever character/professions window anatomy

Research date: **2026-11-10**. Target: the `forever` branch of the [WoW UI source mirror](https://github.com/Gethe/wow-ui-source/tree/forever), observed revision `4cd0ab752a77164f654ccbca9d0c1fe8dafceebe`. This matches the requested client family; generic Retail/Classic descriptions alone do not establish Forever behavior.

## Exact source mapping

| Requested element | Forever source | Addon implementation |
| --- | --- | --- |
| Professions outer window | `Blizzard_ProfessionsFrameBase.xml`: inherits `PortraitFrameTemplate, TabSystemOwnerTemplate` | Inherit only `PortraitFrameTemplate` on an addon-owned frame; no professions owner logic |
| Character outer window | `Camelot/CharacterFrame.xml`: inherits `PortraitFrameBaseTemplate` with its own panes | Confirms the same portrait/title/NineSlice family |
| Portrait and title strip | `SharedUIPanelTemplates.xml`: `PortraitFrameBaseTemplate` supplies `PortraitContainer`, its mask, `TitleContainer.TitleText` and `NineSlice` | Call `SetPortraitToAsset()` and `SetTitle()` from `PortraitFrameMixin` |
| Native metal frame | `NineSliceLayouts.lua`: `PortraitFrameTemplate` uses `UI-Frame-PortraitMetal-CornerTopLeft` and metal edge/corner atlases | Let the inherited NineSlice construct it; no overlay dialog border |
| Close button | `PortraitFrameTemplate` adds `UIPanelCloseButtonDefaultAnchors`; Camelot overrides its size to 28 x 28 and top-right anchor to (0, 3) | Retain the inherited button/script; `onCloseCallback` hides our own frame and returns false to avoid external panel management |
| Right-side icon tabs | Both Camelot character and professions XML use `LargeSideTabButtonTemplate` | Instantiate ordinary frames of that template; the template defines the mask, frame art, selection and hover |
| Tab geometry | `SidePanelTabButtonMixin.CalculateTabSizeBasedOnTabArt()` reads `common-sidetab`; Camelot changes the icon offset to (-4, 0) | Do not resize/reposition the internal artwork. Stack tabs with the professions anchors and a 2-unit gap |
| Press/release and selection | `SidePanelTabButtonMixin`: `SetCustomOnMouseUpHandler`, `SetFillToInterior`, `SetChecked` | Preserve the inherited press/reset/sound handler; activate only on left-button release inside the tab |
| Professions root background | Camelot `ProfessionsMixin:OverrideArt()` sets `Profession-Background-Overview` and hides `TopTileStreaks` | Apply that optional atlas to our inherited `Bg`, otherwise retain native rock |
| Recipe-list texture | `ProfessionsRecipeListTemplate.Background`: `Professions-background-summarylist`, anchored to the whole pane | Apply the same atlas, without tint, to our content panels |
| Interior panel borders | `InsetFrameTemplate` supplies a background and native NineSlice | Use the complete template; retain native marble when the professions atlas is absent |

The Camelot crafting page also adds `Profession-Background-Template2`. That is a large authored page composition, not a generic repeating material; it is not stretched behind each activity card. The recipe-list background is already used by Blizzard as an all-points panel surface.

## Source and API references

- [Shared templates: portrait/inset frames and side tabs](https://github.com/Gethe/wow-ui-source/blob/4cd0ab752a77164f654ccbca9d0c1fe8dafceebe/Interface/AddOns/Blizzard_SharedXML/Mainline/SharedUIPanelTemplates.xml)
- [Portrait/title mixin methods](https://github.com/Gethe/wow-ui-source/blob/4cd0ab752a77164f654ccbca9d0c1fe8dafceebe/Interface/AddOns/Blizzard_SharedXML/PortraitFrame.lua)
- [Side-tab and close-button handlers](https://github.com/Gethe/wow-ui-source/blob/4cd0ab752a77164f654ccbca9d0c1fe8dafceebe/Interface/AddOns/Blizzard_SharedXML/Mainline/SharedUIPanelTemplates.lua)
- [Camelot control-size/icon-offset overrides](https://github.com/Gethe/wow-ui-source/blob/4cd0ab752a77164f654ccbca9d0c1fe8dafceebe/Interface/AddOns/Blizzard_SharedXML/Camelot/SharedUIPanelTemplates.lua)
- [Character window, Camelot](https://github.com/Gethe/wow-ui-source/blob/4cd0ab752a77164f654ccbca9d0c1fe8dafceebe/Interface/AddOns/Blizzard_UIPanels_Game/Camelot/CharacterFrame.xml)
- [Professions base frame](https://github.com/Gethe/wow-ui-source/blob/4cd0ab752a77164f654ccbca9d0c1fe8dafceebe/Interface/AddOns/Blizzard_Professions/Blizzard_ProfessionsFrameBase.xml)
- [Professions tabs and page artwork, Camelot](https://github.com/Gethe/wow-ui-source/blob/4cd0ab752a77164f654ccbca9d0c1fe8dafceebe/Interface/AddOns/Blizzard_Professions/Camelot/Blizzard_ProfessionsFrame.xml)
- [Professions artwork setup, Camelot](https://github.com/Gethe/wow-ui-source/blob/4cd0ab752a77164f654ccbca9d0c1fe8dafceebe/Interface/AddOns/Blizzard_Professions/Camelot/Blizzard_ProfessionsFrame.lua)
- [Recipe-list background and inset](https://github.com/Gethe/wow-ui-source/blob/4cd0ab752a77164f654ccbca9d0c1fe8dafceebe/Interface/AddOns/Blizzard_ProfessionsTemplates/Blizzard_ProfessionsRecipeList.xml)
- [Generated texture API documentation: SetAtlas/SetColorTexture](https://github.com/Gethe/wow-ui-source/blob/4cd0ab752a77164f654ccbca9d0c1fe8dafceebe/Interface/AddOns/Blizzard_APIDocumentationGenerated/SimpleTextureBaseAPIDocumentation.lua)

The client XML defines which elements a template actually creates; Lua mixins define their behavior; generated API documentation defines widget method arguments. Together they are more specific evidence for this window than a generic addon-window tutorial.

## Scope and validation

Only addon-owned frames and shared native artwork are used. The implementation does not open or modify Blizzard's character/professions windows, call profession casting/selection methods, copy gameplay mixins, register gamepad focus handlers or inherit `GamepadSecureBaseDialogTemplate`. Native art is referenced from the client; no extracted textures or Blizzard source files are shipped.

Optional background atlases are checked before use. If absent, the native rock/marble backgrounds remain, with an opaque backing. Side-tab art keeps the template's own geometry. Mock tests cover callback preservation, inside/outside release, selected states, missing optional backgrounds and fitting that includes the protruding sidebar. Source/template existence and passing mocks still require a Forever client check for actual construction, appearance and interaction. No controller support or universal taint safety is claimed.
