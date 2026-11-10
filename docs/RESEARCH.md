# Technical research — 2026-11-06

## Inspected code: Trailblazer

Source: https://github.com/Pinta365/wow-trailblazer

Inspected: Trailblazer.toc, src/Motion.lua, src/Strides.lua, src/History.lua, src/Core.lua.

- Forever manifest targets Interface 16001 with AllowLoadGameType camelot.
- UnitPosition world-coordinate deltas sampled at 0.2 seconds; GetUnitSpeed fallback.
- GetPlayerFacing plus vector dot products for directions.
- Movement events wake sampler; idle sampling sleeps.
- Teleport discontinuity filters and carried-motion/ship heuristics.
- Separate mount, swim, taxi, vehicle, form, ghost movement.
- JumpOrAscendStart hook for jump detection (potentially misses certain inputs).
- Race/sex/gait-specific measured stride table and calibration.
- Daily, monthly and lifetime SavedVariables storage.

The inspected repository metadata did not declare a license. We borrow ideas, **not code or measured stride data**.

## Other competitors

Dalorrian's Step Counter and Mostly Walking were investigated as search targets, but independently verifiable source repositories were not established. Their code is not represented as reviewed.

## Classification

| Metric | Method | Confidence |
| --- | --- | --- |
| Distance | UnitPosition horizontal displacement | Direct coordinate measurement (sampling caveats) |
| Distance fallback | GetUnitSpeed * time | Estimate |
| Steps | Distance / estimated race stride | Estimate |
| Forward/back/strafe | Delta versus facing vector | Inference |
| Walk/run | Current speed relative to run speed | Inference |
| Jump | Jump input then falling transition | Heuristic |
| Mount, swim, taxi | Game API flags | State classification |
| Murlocalories | Weighted game activity | Fiction |
| Murloc kills | Combat-log NPC detection and attribution | Deferred; not verified |

## Forever QA to complete

1. Live API existence and IsSecretValue behavior during combat.
2. Coordinates inside dungeons and while on ships.
3. Teleports, flight paths, vehicles and rapid movement.
4. Jump hook with default and remapped keybindings.
5. Left/right sign test on ground.
6. Mounted and shapeshifted movement.
7. Locale, UI size, local-day rollover and SavedVariables persistence.

Architecture: Core manages ledgers; Motion and Jump generate events; UI reads state. No external service, injected movement commands or borrowed external licensed assets.

## Native UI source check — 2026-11-10

Inspected the `forever` branch of [Gethe/wow-ui-source](https://github.com/Gethe/wow-ui-source/tree/forever), including `Blizzard_SharedXML/Mainline/SharedUIPanelTemplates.xml`, `Blizzard_SharedXML/CommonUIPanelTemplates.xml`, `Blizzard_UIPanelTemplates/Mainline/UIPanelTemplates.xml` and `Blizzard_Minimap/Mainline/Minimap.xml`. These establish source-level evidence for native buttons, close buttons, inset frames and status-bar textures, not permission to instantiate every template or proof of in-game appearance. The preview uses ordinary addon-owned Backdrop frames, native controls, dialog/tooltip borders and masked minimap art; it avoids secure/gamepad templates. The owner's Overlord screenshot is a styling reference, not a source of copied assets.
