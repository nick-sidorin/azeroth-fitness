# Azeroth Fitness UI direction

This records the owner's current design choices. No Quest Hints Forever now has a pinned shared development standard; its native-widget guidance was reviewed for this change. Vendoring that dependency here is a separate task. This document is not evidence of final client rendering.

## Identity and references

- Always use **Azeroth Fitness**, including the addon list, window, tooltip and chat. Translate interface copy, never the brand.
- The owner's Forever character and herbalism screenshots define the window structure: portrait at the upper left, native title strip/close button, textured interior and right-side icon tabs. Overlord remains a secondary styling reference; do not copy its images, banners or code.
- Fitness supplies the playful activity-goal model. The current implementation uses three horizontal meters; rings are a later iteration. Do not reproduce Apple assets.
- Follow No Quest Hints Forever's verified engineering patterns: native fonts/controls, no forbidden secure templates, complete locale dictionaries, no language picker, shared regression/package gates and client QA for visuals.

## Surfaces and hierarchy

- The frame is an adventure ledger, not a transparent overlay. A solid alpha-1 base must cover every content surface. Native artwork may contain transparent pixels even when its vertex alpha is 1.
- Inherit the ordinary `PortraitFrameTemplate`, as the professions frame does. Keep its native portrait container/mask, title container, NineSlice metal border and close button. Set the brand via `SetTitle()` and Sprint icon via `SetPortraitToAsset()`; do not draw a second header or border over the template.
- Use `Profession-Background-Overview` on the root background and `Professions-background-summarylist` on native `InsetFrameTemplate` content panels. Keep their original tint. If an optional atlas is absent, preserve the template's authored rock/marble texture. Do not darken several layers until the grain disappears.
- Navigation uses `LargeSideTabButtonTemplate` frames down the right edge. Keep authored dimensions, native icon masks and selected/hover/press visuals. Labels belong in localized native tooltips, rather than another row of text buttons.
- Route activation through `SetCustomOnMouseUpHandler()` with a left-button/inside check and selected state through `SetChecked()`. Preserve inherited mouse scripts. Use the native close callback and append window-fit work with `HookScript()`.
- A quiet humor line may sit beneath the native title strip, but the brand keeps the native title size and alignment.
- Each activity card has a colored label, a large current value, a smaller subdued target, a percentage and one textured status bar. Lime means steps, cyan means jumps and rose means fictional Murlocalories. Label/value context accompanies color.
- Secondary distance details stay below the activity cards; measurement caveats use small readable text at the bottom. Save actions remain native action buttons. Avoid decorative paragraphs, giant headers and dense feature lists.

## Layout and behavior

- Base window: 600 x 590 UI units. Opening fits the full width including protruding tabs/portrait to 94% of the available UI dimensions. Native fonts use the current client's face for Cyrillic/CJK coverage.
- Labels receive fixed layout space; longer messages wrap. Check the 12 locales in client rather than assuming English lengths apply everywhere. Side tabs use their native localized tooltip behavior.
- Header drag, Escape closing and all four views remain available. The minimap shortcut is circular, movable along the map edge, and saves its angle. Poll cursor position only during a drag.
- The game selects the language on load via `GetLocale()`. English and Spanish regional variants share dictionaries; unknown locales fall back to English. Ignore old language overrides without touching activity history.
- Host the existing settings form in the native AddOns canvas category when its APIs are available; keep that same form embedded only as a capability fallback. Refresh from live SavedVariables on native show/refresh, preserve unsaved edits on repeated opens and never duplicate saved settings state. Native settings also contain the final copyable Issues-link action.
- Create the dashboard refresh ticker on show and cancel it on hide. Native settings are static until the user acts; they need no activity polling.

## Verification boundary

Lua mocks check widget choices, inherited callback preservation, press/release behavior, opaque backing, optional-atlas fallback, sidebar-aware fitting, state changes, locale completeness and number/goal behavior. They cannot prove constructor permission, artwork appearance, glyph coverage or translated line fit. See [the source/API mapping](NATIVE_UI_RESEARCH.md). Give the owner a single installation-ready preview ZIP and collect a real-client screenshot before merging this visual iteration. No public release is implied.
