# Changelog

Versions follow Semantic Versioning.

## [Unreleased]
### Added
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
