# Azeroth Fitness UI direction

This records the owner's current design choices, pending the shared addon guideline being prepared in the neighboring No Quest Hints Forever project. It is not evidence of final client rendering.

## Identity and references

- Always use **Azeroth Fitness**, including the addon list, window, tooltip and chat. Translate interface copy, never the brand.
- Overlord is the reference for a crafted Warcraft interface: dense textured surfaces, warm metal edges, an emblem-like header and clear content grouping. Do not copy its images, banners or code.
- Fitness supplies the playful activity-goal model. The current implementation uses three horizontal meters; rings are a later iteration. Do not reproduce Apple assets.
- Follow No Quest Hints Forever's verified engineering patterns: native fonts/controls, no forbidden secure templates, complete locale dictionaries, no language picker, shared regression/package gates and client QA for visuals. The future shared guide can refine these decisions.

## Surfaces and hierarchy

- The frame is an adventure ledger, not a transparent overlay. A solid alpha-1 base must cover every content surface. Native artwork may contain transparent pixels even when its vertex alpha is 1.
- Tile `Interface/FrameGeneral/UI-Background-Marble` over that base. Keep the grain visible with a warm stone tint. Never rely on the alpha-containing dialog background alone for opacity.
- Use the native gold dialog border for the outer frame and a thinner muted brass tooltip border for interior panels. Avoid stacking several ornate borders around the same region.
- The framed header carries the Sprint emblem, stable brand and one quiet humor line. Its crest uses native minimap-ring art, not a new third-party logo.
- Native `PanelTopTabButtonTemplate` navigation replaces four red action buttons. Use the native selected/deselected tab states and authored tab art rather than imitating them with flat rectangles.
- Each activity card has a colored label, a large current value, a smaller subdued target, a percentage and one textured status bar. Lime means steps, cyan means jumps and rose means fictional Murlocalories. Label/value context accompanies color.
- Secondary distance details stay below the activity cards; measurement caveats use small readable text at the bottom. Save actions remain native action buttons. Avoid decorative paragraphs, giant headers and dense feature lists.

## Layout and behavior

- Base window: 600 x 650 UI units. Opening fits it to 94% of the available UI dimensions. Native fonts use the current client's face for Cyrillic/CJK coverage.
- Labels receive fixed layout space; longer messages wrap. Check the 12 locales in client rather than assuming English lengths apply everywhere. Native tabs provide their own truncated-label tooltip behavior.
- Header drag, Escape closing and all four views remain available. The minimap shortcut is circular, movable along the map edge, and saves its angle. Poll cursor position only during a drag.
- The game selects the language on load via `GetLocale()`. English and Spanish regional variants share dictionaries; unknown locales fall back to English. Ignore old language overrides without touching activity history.

## Verification boundary

Lua mocks check widget choices, opaque base/texture setup, state changes, locale completeness, format placeholders and number/goal behavior. They cannot prove the artwork's appearance, glyph coverage or translated line fit. Give the owner a single installation-ready preview ZIP and collect a real-client screenshot before merging this visual iteration. No public release is implied.
