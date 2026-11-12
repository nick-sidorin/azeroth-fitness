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

## Achievement cards and alerts — 2026-11-10

Reference: matching `forever` branch of [Gethe/wow-ui-source](https://github.com/Gethe/wow-ui-source/tree/forever). Inspected the following authored resources and callback contracts:

- `Blizzard_AchievementUI/Mainline/Blizzard_AchievementUI.xml` and `.lua`: `UI-Achievement-Parchment-Horizontal` and its `-Desaturated` variant, `UI-Achievement-Borders` earned/locked title UVs, `UI-Achievement-IconFrame` and `UI-Achievement-Shields`. Use the parchment bottom crop for compact 104-unit rows.
- `Blizzard_FrameXML/Mainline/AlertFrames.xml`, `AlertFrames.lua` and `AlertFrameSystems.xml`: `ui-achievement-alert-background`, `ui-achievement-iconframe` and `ui-achievement-shield-1`; 300 x 101 alert geometry. Use checked atlases at authored sizes and known parchment/icon/shield file fallback.
- `Blizzard_SharedXML/Shared/Scroll/{ScrollBar.xml,ScrollTemplates.xml,MinimalScrollBar.xml,ScrollBar.lua}`: `VerticalScrollBarTemplate` is an incomplete base with no track/thumb, so instantiate the complete `MinimalScrollBar`. `Init(visibleExtentPercentage, panExtentPercentage)` and `RegisterCallback("OnScroll", callback, owner)` map its native controls to the engine ScrollFrame offset. Mouse wheel uses the same percentage setter.

Native `AchievementTemplate` and `AchievementAlertFrameTemplate` depend on real Blizzard achievement IDs, load-on-demand data and shared alert infrastructure. The addon therefore uses ordinary frames with these native textures and its own SavedVariables; it does not load Blizzard_AchievementUI, fabricate game achievement IDs, change global alert pools or award real character achievement points. This is source evidence, not a claim of in-client rendering or taint validation.

## Achievement artwork correction — 2026-11-11

Owner screenshots confirm functional earning, scrolling and notifications but expose cropped/magnified shield art, mismatched icon/frame anchors, unreadable earned descriptions and missing card/viewport borders. No downloaded image assets are bundled: the prior renderer referenced native client artwork but assembled it incorrectly.

The previous toast first applied a quarter-sheet file crop, then called `SetAtlas` without explicit UV reset. Use `SetAtlas(name, true, "LINEAR", true)` on clean textures, retaining authored dimensions. Only the missing-atlas fallback uses the documented file-sheet UVs. The regression models a nontrivial atlas region and rejects the old renderer's stale crop.

`Blizzard_FrameXML/Mainline/AlertFrameSystems.xml` defines the actual alert geometry: 300 x 101 frame; 78 x 75 icon container at (-4, -15), 52 x 52 image centered, overlay offset (-1, 2); 64 x 64 shield container at top-right (-8, -15), shield art at (1, -6), points centered (3, -2). The name has a 155 x 36 region below the 12-unit unlocked heading and explicit middle justification/two-line limit. Preserve draw layers and default scale; do not enlarge the sprite or treat the whole texture sheet as one icon. The 60-unit list icon container likewise follows the native (0, 3) image / (-1, 2) border relationship.

Cards now use dark `InsetFrameTemplate` recipe-list textures rather than stretching the legacy parchment across each row. White earned copy with shadow, grey locked copy/icons and native inset borders provide readable separation. A gold StatusBar in a native inset displays total points. The entire scroll viewport is inset-framed. The side tab uses the native laurel-shield atlas with a PvP medal icon fallback. The missing-toast-atlas fallback is a complete native inset surface rather than an unrelated parchment image.

Mock regressions cover both atlas-present and atlas-missing branches, UV reset, authored dimensions, relative icon/shield anchors, text justification/contrast, point-bar values and native frames. They do not render the game or prove subjective sharpness at the owner's UI scale; verify the next preview in Forever.

## Approved toast and textured card correction — 2026-11-11

The owner approved the corrected toast artwork, icon and typography. Keep its constructor unchanged; only its score's anchor changes to the shield texture center at (3, 0). The image is top-inset inside the 64-unit holder, so this moves the digits down four UI units while retaining the horizontal native-art compensation. List badge digits remain unchanged.

The owner screenshot rejects the nearly flat card result from stretching `Professions-background-summarylist` into a 524 x 104 card. Use the original `UI-Achievement-Parchment-Horizontal` / `-Desaturated` files again, with a 516 x 96 interior and the documented bottom crop. Native grain remains visible behind a translucent black shade; no opaque color wash covers the texture. The card border uses `UI-Tooltip-Border` at edge size 12, the same native art family used by the original achievement template. Retain the inset around the entire scroll viewport and restore the earned/locked native title-strip UVs. The points bar now includes an unfilled textured track. This is a client-art composition change, without new assets or real-achievement APIs.

## Card progress and notification navigation — 2026-11-11

Use an ordinary Button for the addon toast, registering `LeftButtonUp`; do not inherit Blizzard’s real-achievement click handlers. Route through addon-owned sorted IDs and the existing scroll percentage API. Green card meters use the already supported StatusBar/tooltip-border/`UI-StatusBar` art family; they are not native Blizzard achievement criteria providers. The points FontString now fills the entire shield image and centers vertically/horizontally, replacing the older optical offsets. The toast art, icon and name geometry remain as approved by the owner. Native tooltip ownership is checked on cleanup to avoid hiding another widget’s tooltip.

## Native progress border and earned-card layout — 2026-11-12

Inspected `AchievementProgressBarTemplate` in the matching `forever` `Blizzard_AchievementUI/Mainline/Blizzard_AchievementUI.xml`. Its visual construction is specific: a 212 x 14 StatusBar, a 40%-opaque black track, `UI-StatusBar` fill colored (0, .6, 0, 1) at BORDER, and `UI-Achievement-ProgressBar-Border` at ARTWORK. Three slices preserve the shadow/corners: 16-unit endcaps spanning from 5 units above to 5 below the bar, left/right outsets of 6, UVs (0, .0625, 0, .75), (.0625, .812, 0, .75), and (.812, .8745, 0, .75). Reconstruct this artwork on an ordinary addon-owned StatusBar; do not load real-achievement providers or inherit their load-on-demand template. This replaces the generic tooltip-border surround rather than stacking another border on it.

The owner’s new reference requests centered card copy, short bars only on unearned cards, a raised points shield with an earned date below, and dark earned goals on brighter parchment. Keep the existing font objects. Render short dates with locale-ordered numeric slashes (MDY enUS, DMY European/enGB, YMD Korean/Chinese), without changing ISO SavedVariables dates. The approved toast and notification navigation are unchanged. Automated tests check draw layers, art/cap geometry, visibility transitions, date layout/order and restoring unfinished text after reset; actual depth/contrast still needs client rendering.
