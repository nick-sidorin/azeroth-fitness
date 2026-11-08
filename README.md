# Azeroth Fitness

**Your adventurer has walked 25,000 steps. You have not left your chair.**

Azeroth Fitness is an experimental activity tracker for **World of Warcraft: Forever**. It tracks character travel, estimates footsteps, records jumps and calculates fictional Murlocalories.

> **v0.1.0 is experimental: Forever in-client validation is still required.**

## Features

- Daily estimated footsteps and configurable step target
- Character-specific lifetime totals, best day and goal streak
- 7-day and 30-day history charts
- Walking, running, backpedaling, left/right strafing and swimming distances
- Jumps and fictional Murlocalories
- Seven humorous achievements
- English and Russian UI, automatic game-locale selection
- Native UI, minimap button and slash commands

## Installation

1. Obtain the release ZIP and extract it to the Forever Interface/AddOns directory.
2. The extracted folder must be named AzerothFitness and contain AzerothFitness.toc at the top level.
3. Enable the addon and use /af in game.

The GitHub source ZIP is not the packaged addon; a ZIP is assembled by GitHub Actions on tagged releases.

## Commands

- /af — toggle window
- /af stats — today's statistics
- /af history — daily chart
- /af settings — goal, stride and language
- /af debug — last motion mode / measurement source

## Measurement integrity

**Steps are estimated, not observed animation footfalls.** Distance (yards) is divided by a configurable race-aware stride estimate. The default race figures are coarse guesses, not empirically validated values. Running stride may be set per character; walking/backpedaling use proportionally smaller estimates.

World-space horizontal movement is measured with UnitPosition where readable. If coordinates are unavailable, GetUnitSpeed times elapsed seconds supplies a **speed-based estimate**. If both fail, the addon does not fabricate distance. Movement is sampled about five times per second only when moving. Large discontinuities and suspicious transport displacement are discarded.

Facing versus world-position deltas is used to infer backward/left/right travel. When coordinates are unavailable, travel direction is recorded as **unknown**, not automatically forward. Walk versus run is inferred from speed.

A jump is recorded when a player-initiated JumpOrAscendStart is followed by an IsFalling transition. This may miss alternate bindings or very short transitions and is unverified in the active Forever client.

**Murlocalories are fictional, not physical calories.** Per 100 yards: running/unknown 1.8, walking 1.2, backpedaling 2.2, strafing 2.4, swimming 2.0. Confirmed jump adds 0.75. Mounts and transportation add zero.

Data is saved locally as AzerothFitnessDB via the WoW SavedVariables system, keyed by character GUID. Dates use the computer's local date, not the server reset. The current-day target is editable; older completed days retain their recorded targets. Data typically flushes to disk on logout or UI reload.

## Forever compatibility

Based on the publicly available Trailblazer addon manifest, the TOC targets Interface 16001 and AllowLoadGameType camelot. **The engine and UI have not yet been smoke-tested in a live Forever game client**, so function availability, jump hooks, movement direction signs and combat secret-value handling remain validation tasks.

## Research and credits

The public source of [Trailblazer](https://github.com/Pinta365/wow-trailblazer) was studied for API and algorithm design. This project independently implements its own modules and does not copy any source or stride table. Trailblazer's repository did not expose a license in the inspected metadata; direct code copying would require appropriate permission.

For contributors and coding agents: start with [AGENTS.md](AGENTS.md) and the [complete project and decision handoff](docs/PROJECT_CONTEXT.md).

See [technical research](docs/RESEARCH.md), [changelog](CHANGELOG.md) and [MIT license](LICENSE).

Unaffiliated with Apple, Blizzard or the WoW: Forever team.

## Roadmap

- [x] Local daily ledger and lifetime totals
- [x] Position/speed movement sampler and estimated steps
- [x] Jump heuristic and Murlocalories
- [x] Native EN/RU UI and daily charts
- [ ] Forever client smoke tests and compatibility fixes
- [ ] Calibration and automated tests
- [ ] More polished charts/activity rings
- [ ] Public release after verification
