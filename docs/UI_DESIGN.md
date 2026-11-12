# Azeroth Fitness UI direction

This records the owner's current design choices. This repository vendors the same reviewed, pinned shared standard as No Quest Hints Forever; see `docs/standards/README.md` and `docs/STANDARDS_ALIGNMENT.md`. This document is not evidence of final client rendering.

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

## Achievement view

The award-icon sidebar tab replaces Records. Use native achievement parchment on each card, with a translucent black shade for white-text contrast. Keep its grain visible; do not stretch the tall profession-list atlas into short cards. Earned and locked cards use the colored/desaturated parchment variants and a thin native tooltip-art border. Earned cards use bright parchment with dark, shadow-free goal text and a light title on its header strip. The scroll viewport keeps its native inset border. Keep native achievement icon frames and laurel point shields at authored atlas dimensions; reset UVs explicitly when switching from a file sheet to an atlas. Anchor image/border/points inside their native-sized icon and shield subframes. Display the total in a gold status bar with a textured unfilled track and a centered localized points label. Center titles and goals across the card. Raise the list shield and place its earned date below the artwork. Format dates with slashes in the client locale’s date order; preserve ISO saved dates. A native `MinimalScrollBar` controls a clipped engine `ScrollFrame`; keep its thumb, track and arrow behavior. Earned rows sort first, then stable definition order. Each award gives 10 points. Put best day, step streak and lifetime totals in History above the chart.

Unfinished cards include a centered 212 x 14 status bar and localized current/target counter. Match `AchievementProgressBarTemplate`: its three-part border/shadow artwork at ARTWORK, fill at BORDER with color (0, .6, 0), and a 40% black track at BACKGROUND. Hide the entire meter once earned, retaining completion in data. Only earned cards display a date, under the shield.

Newly earned awards queue a clickable alert using native achievement atlases and the authored 300 x 101 geometry at 30% of UIParent height above the bottom. The owner approved the existing toast appearance; preserve its background, icon, fonts, name placement, size and animation. The toast is an addon-owned Button: left-click opens the Achievements tab and scrolls by stable award ID, highlighting the card. Dismiss only the clicked alert and preserve the remaining queue. A localized native tooltip explains the click. Do not reset scroll on routine refresh; retain the focused ID through sorting. Center the points font region over the full shield texture, with horizontal/vertical font alignment and no manual per-digit offsets. Animate only while a notification is active; clear pending alerts on a confirmed testing reset. Do not use Blizzard achievement IDs or insert addon entries into native alert pools. No progress notifications.

## Verification boundary

Lua mocks check widget choices, inherited callback preservation, press/release behavior, opaque backing, optional-atlas fallback, sidebar-aware fitting, state changes, locale completeness and number/goal behavior. They cannot prove constructor permission, artwork appearance, glyph coverage or translated line fit. See [the source/API mapping](NATIVE_UI_RESEARCH.md). Give the owner a single installation-ready preview ZIP and collect a real-client screenshot before merging this visual iteration. No public release is implied.
