# Changelog

Versions follow Semantic Versioning.

## [Unreleased]
### Added
- Three nested, round-capped daily activity rings using the native radial texture API, with numeric goals and a horizontal-meter capability fallback
- Adopt shared standards 0.1.1 requiring native component and documented API discovery before custom Blizzard-style UI
- Click earned notifications to open the Achievements tab, scroll to the matching sorted card and highlight it without discarding queued alerts
- Green achievement-card progress bars with localized current/target counters, driven by the same metrics/thresholds as unlocking
- Eight 10-point addon achievements, including First Steps at 50 estimated steps; framed native textured cards, a total-points bar and desaturated locked state and earned-first scrolling list
- Queued achievement-earned notifications independent of dashboard visibility, with native alert artwork
- Temporary `/af reset` testing command with current-character-only native confirmation; preserve settings and other characters
- Pinned shared addon-development standards, offline integrity gate and reviewed sync/update procedure
- Native AddOns settings category sharing one live form with the fallback, plus a localized copyable Issues link
- Complete dictionaries for all 12 official WoW client locales with automatic game-language selection and English fallback
- Native portrait-frame window with Blizzard title strip, portrait, close button and right-side icon tabs from Forever's character/professions UI
- Professions overview/recipe-list textures, native inset panels, three horizontal daily activity bars and separate current-value/target typography
- Source/API research mapping the selected templates, atlases and inherited callbacks
- Separate configurable daily jump and Murlocalorie targets, preserving existing step/history data
- Masked circular Sprint minimap shortcut with drag positioning, saved angle, right-click settings and visibility control
- Sprint addon-list icon, localized achievement text, Escape closing and adaptive window scaling
- UI, minimap interaction and additive goal-upgrade regression suites
- PR and manual preview builds using the `build` check, matching the No Quest Hints Forever workflow
- Shared Lua 5.1 syntax and mocked regression gates for accounting, motion and jump logic
- TOC-derived reproducible ZIP packaging with archive regression tests and direct-install test artifacts
- Explicit release-request publisher for approved stable and alpha/beta releases
- CurseForge source-packager configuration and reusable listing description

### Changed
- Center card titles/goals and use Blizzard’s short three-slice progress border with shadow, translucent track and inset green fill
- Hide meters on earned cards; show dark goal text on bright parchment and a locale-ordered slash date below the raised shield
- Rename Records to Achievements with an award icon; move best day, step-goal streak and lifetime totals to History
- Keep the Azeroth Fitness brand untranslated in every locale and remove language-selection buttons
- Localize number separators/distance units and accept decimal commas in stride input

### Fixed
- Keep earned dates inside card bounds on the shield foreground layer with contrasting text, independent of atlas padding
- Retry Lua source-download transport errors and fall back to a digest-identical BLFS mirror when lua.org is unavailable
- Center points across the full shield texture in both alerts and cards, removing fixed per-digit offsets
- Restore visible colored/desaturated achievement parchment with translucent shading, thin native borders and aligned card text
- Preserve the approved earned toast and center only its digits on the inset shield artwork; add the total-points bar’s textured track
- Pin build/publisher runners to Ubuntu 24.04 and build the SHA-256-verified official Lua 5.1.5 source instead of depending on failing Ubuntu package mirrors
- Reset atlas UVs explicitly to prevent cropped/magnified achievement-alert shields and icon frames
- Match native icon/shield subframe geometry and centered two-line alert names; keep atlas artwork at authored dimensions
- Replace dark earned descriptions with white shadowed text, add card/list borders and use a laurel-shield sidebar icon
- Cancel dashboard refresh timers when hidden instead of waking an idle ticker
- Prevent transparent dialog art from exposing the world through the main window and panels
- Avoid displaying 28% for 29 out of 100 jumps through floating-point truncation


### Still required
- Live Forever client compatibility testing and measurement fixes; the measurement engine remains experimental

## [0.1.0] - 2026-11-06
### Added
- Initial SavedVariables daily, lifetime and per-character ledgers
- Event-driven horizontal movement sampler, position/speed fallback
- Estimated footsteps and fictional Murlocalories
- Jump-input with falling-state confirmation
- English/Russian dashboard, history charts and achievement records
- Slash commands and minimap button
- GitHub Actions packaging

### Known limitations
- Not yet tested in a running Forever client
- Approximate race stride lengths
- Some jump bindings and transport movements may not classify correctly
