# Changelog

Versions follow Semantic Versioning.

## [Unreleased]
### Added
- Complete dictionaries for all 12 official WoW client locales with automatic game-language selection and English fallback
- Opaque tiled native stone surfaces, framed header, Blizzard top tabs and clearer current-value/target typography
- WoW-native gold-framed dashboard with three horizontal daily activity bars, native buttons and client font faces
- Separate configurable daily jump and Murlocalorie targets, preserving existing step/history data
- Masked circular Sprint minimap shortcut with drag positioning, saved angle, right-click settings and visibility control
- Sprint addon-list icon, localized achievement text, Escape closing and adaptive window scaling
- UI, minimap interaction and additive goal-upgrade regression suites

### Changed
- Keep the Azeroth Fitness brand untranslated in every locale and remove language-selection buttons
- Localize number separators/distance units and accept decimal commas in stride input

### Fixed
- Prevent transparent dialog art from exposing the world through the main window and panels
- Avoid displaying 28% for 29 out of 100 jumps through floating-point truncation
- PR and manual preview builds using the `build` check, matching the No Quest Hints Forever workflow
- Shared Lua 5.1 syntax and mocked regression gates for accounting, motion and jump logic
- TOC-derived reproducible ZIP packaging with archive regression tests and direct-install test artifacts
- Explicit release-request publisher for approved stable and alpha/beta releases
- CurseForge source-packager configuration and reusable listing description

### Still required
- Live Forever client compatibility testing and measurement fixes; addon runtime remains unchanged from the experimental 0.1.0 baseline

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
