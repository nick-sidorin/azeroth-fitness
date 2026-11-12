# Azeroth Fitness

**Your adventurer has walked 25,000 steps. You have not left your chair.**

Azeroth Fitness is an experimental activity tracker for **World of Warcraft: Forever**. It tracks character travel, estimates footsteps, records jumps and calculates fictional Murlocalories.

> **v0.1.0 is experimental: Forever in-client validation is still required.**

## Features

- Daily estimated footsteps, jumps and fictional Murlocalories with separate configurable targets
- Character-specific lifetime totals, best day and goal streak
- 7-day and 30-day history charts
- Walking, running, backpedaling, left/right strafing and swimming distances
- Jumps and fictional Murlocalories
- Eight humorous achievements with points, scrollable native-style cards and earned-first sorting
- All 12 official WoW client locales, selected automatically from the game language
- Native portrait-frame dashboard with right-side icon tabs, horizontal activity bars and client fonts
- Round minimap shortcut with a running/boots icon, drag positioning, saved angle and visibility setting

## Installation

1. Download a test ZIP from [GitHub Actions](https://github.com/nick-sidorin/azeroth-fitness/actions) or a published version from [GitHub Releases](https://github.com/nick-sidorin/azeroth-fitness/releases), then extract it to the Forever Interface/AddOns directory.
2. The extracted folder must be named AzerothFitness and contain AzerothFitness.toc at the top level.
3. Enable the addon and use /af in game.

Test artifact downloads contain `AzerothFitness/` directly, without a nested ZIP. The GitHub source ZIP is not the packaged addon. Test builds retain the current TOC version and remain experimental until verified in Forever.

## Commands

- /af — toggle window
- /af stats — today's statistics
- /af history — daily chart
- /af settings — daily goals, stride and minimap visibility
- /af debug — last motion mode / measurement source
- /af reset — temporary testing command; confirm erasing the current character’s activity history, totals and achievements (keeps settings and other characters)

## Dashboard and daily goals

The dashboard inherits the same `PortraitFrameTemplate` used by Forever's professions window: native portrait, title strip, nine-slice border and close button. Its right-side icon tabs use `LargeSideTabButtonTemplate`, as in the character/professions windows. Inner frames use the professions recipe-list texture at its original tint, with native rock/marble fallback. The Fitness-inspired activity bars remain addon-owned content. No Overlord or Apple art is included; circular activity rings remain future work. See [UI design decisions](docs/UI_DESIGN.md) and the [native-source/API research](docs/NATIVE_UI_RESEARCH.md).

Each day has three goals: estimated steps (default 10,000), jumps (100) and fictional Murlocalories (300). Change them under **Settings**. The current day's targets update together; previous days retain their saved targets. Existing historical records do not acquire invented jump/Murlocalorie goals when upgrading. The step streak remains based on the daily step target.

Left-click the minimap shortcut to toggle the dashboard, right-click for settings, or drag it around the edge of the minimap. Its angle and visibility persist across reloads. The same Blizzard Sprint icon identifies the addon in the addon list. The header drags the window, and Escape closes it. Window scale adapts when opened on a small UI.

Settings register under **Options → AddOns → Azeroth Fitness** when the native canvas API is available. `/af settings`, the settings side tab and minimap right-click open that same form, using current saved goals/stride/minimap preferences. Clients without that API retain the embedded form; there is no second settings store. **Report a problem** opens a copyable Issues URL with localized instructions. It does not open a browser or submit a report. Dashboard refresh timers exist only while the activity window is visible.

**Azeroth Fitness** is the brand in every language and is never translated. The interface follows `GetLocale()` without a language selector or SavedVariables override. Supported client locales: `enUS`, `enGB`, `ruRU`, `deDE`, `frFR`, `esES`, `esMX`, `itIT`, `ptBR`, `koKR`, `zhCN`, `zhTW`. English and Spanish variants share translations; English is the fallback for unknown locales or missing keys. Numbers and distance units follow the client locale. The localization structure follows No Quest Hints Forever.

Native component use and mock tests do not establish the final appearance in every Forever build. Please check translated text, joke wording, frame sizing, minimap positioning and different UI scales in game. Dictionary completeness is tested; native-speaker and client layout reviews remain useful.

## Achievements

The award-icon tab contains only achievements: eight parchment-textured cards worth 10 points each, thin native borders, a gold total-points bar, dark earned goals and desaturated locked icons. Earned cards appear first. Best day, goal streak and lifetime totals now live in **History**. Existing earned dates remain saved; points are calculated from known awards without rewriting history.

**First Steps** unlocks after 50 estimated lifetime steps. Unfinished cards have centered goals and a short inset green progress bar with a current/target counter. Distance counters use meters or yards. Earned cards hide the bar, show dark goal text on bright parchment and place a short slash-formatted date under the raised points shield; saved completion remains intact when a streak expires. Newly earned achievements display a queued Blizzard-style notification at the lower center of the screen, even when the dashboard is closed. Left-click the notification to open the Achievements tab, scroll to that award and highlight its card; other queued notifications remain available. These are addon achievements, separate from Blizzard character achievement points. Progress appears on the cards; notifications announce newly earned awards only. For testing, `/af reset` opens a native confirmation before deleting this character’s statistics; Cancel/Escape or unavailable confirmation leaves them intact.

## Measurement integrity

**Steps are estimated, not observed animation footfalls.** Distance (yards) is divided by a configurable race-aware stride estimate. The default race figures are coarse guesses, not empirically validated values. Running stride may be set per character; walking/backpedaling use proportionally smaller estimates.

World-space horizontal movement is measured with UnitPosition where readable. If coordinates are unavailable, GetUnitSpeed times elapsed seconds supplies a **speed-based estimate**. If both fail, the addon does not fabricate distance. Movement is sampled about five times per second only when moving. Large discontinuities and suspicious transport displacement are discarded.

Facing versus world-position deltas is used to infer backward/left/right travel. When coordinates are unavailable, travel direction is recorded as **unknown**, not automatically forward. Walk versus run is inferred from speed.

A jump is recorded when a player-initiated JumpOrAscendStart is followed by an IsFalling transition. This may miss alternate bindings or very short transitions and is unverified in the active Forever client.

**Murlocalories are fictional, not physical calories.** Per 100 yards: running/unknown 1.8, walking 1.2, backpedaling 2.2, strafing 2.4, swimming 2.0. Confirmed jump adds 0.75. Mounts and transportation add zero.

Data is saved locally as AzerothFitnessDB via the WoW SavedVariables system, keyed by character GUID. Dates use the computer's local date, not the server reset. The current-day target is editable; older completed days retain their recorded targets. Data typically flushes to disk on logout or UI reload.

## Forever compatibility

Based on the publicly available Trailblazer addon manifest, the TOC targets Interface 16001 and AllowLoadGameType camelot. The owner has opened earlier UI previews in Forever and supplied screenshots. The owner approved the portrait-frame preview for merging. The owner reports that achievement behavior works; the corrected artwork/layout and measurement edge cases still require validation: function availability, jump hooks, movement direction signs and combat secret-value handling are not established by those screenshots.

## Research and credits

The public source of [Trailblazer](https://github.com/Pinta365/wow-trailblazer) was studied for API and algorithm design. This project independently implements its own modules and does not copy any source or stride table. Trailblazer's repository did not expose a license in the inspected metadata; direct code copying would require appropriate permission.

For contributors and coding agents: start with [AGENTS.md](AGENTS.md) and the [complete project and decision handoff](docs/PROJECT_CONTEXT.md).

See [technical research](docs/RESEARCH.md), [changelog](CHANGELOG.md) and [MIT license](LICENSE).

Unaffiliated with Apple, Blizzard or the WoW: Forever team.

## Roadmap

- [x] Local daily ledger and lifetime totals
- [x] Position/speed movement sampler and estimated steps
- [x] Jump heuristic and Murlocalories
- [x] Native localized UI and daily charts
- [ ] Forever client smoke tests and compatibility fixes
- [ ] Calibration and automated tests
- [ ] More polished charts/activity rings
- [ ] Public release after verification

## Development, builds and releases

Development follows the [pinned shared addon standards](docs/standards/README.md), version 0.1.0 at `f36540efe61eb90671be1359849cbc6d2ddd85c1`, following the No Quest Hints Forever adoption pattern. The [lock](docs/standards/standards.lock.json) records document hashes. `python3 scripts/standards.py check` verifies local integrity offline and runs in CI; updates require a reviewed commit and adoption PR. The addon does not load or package this dependency. See the [alignment audit](docs/STANDARDS_ALIGNMENT.md) for main versus pending UI work and the [release handoff contract](docs/RELEASE_HANDOFF.md).

This repository follows the same GitHub Flow as [No Quest Hints Forever](https://github.com/nick-sidorin/no-quest-hints-forever): feature branch → PR into `main` → passing `build` → squash merge. The owner configures repository rules separately: require PRs and the `build` status check, and allow only squash merging. A passing check does not prove that branch protection requires it.

Build and publisher jobs use a pinned Ubuntu 24.04 runner image. `scripts/install_lua51.sh` compiles Lua 5.1.5 from the official HTTPS archive (with a BLFS mirror fallback) after verifying the same pinned SHA-256, using the runner’s C compiler and make; no APT mirror is required. The script takes an absolute install directory, and local contributors may instead use their existing Lua 5.1 installation.

Run the shared gate locally with Python 3.9+ and Lua 5.1:

```sh
bash scripts/run_ci.sh
python3 scripts/package_addon.py dist/AzerothFitness-v0.1.0.zip
```

The gate discovers `tests/test_*.lua`, validates all addon/test Lua syntax with `luac5.1`, runs the Lua suites and Python packaging tests, and verifies Forever metadata and TOC/Core version consistency. Tests use mocked APIs; they do not establish in-game compatibility. `scripts/package_addon.py` builds a reproducible ZIP from the TOC plus LICENSE and verifies every member against source bytes. Internal docs, scripts and tests are excluded.

**PR and manual builds:** [Build and release](.github/workflows/release.yml) runs on PRs targeting `main`, manual dispatch, and `v*` tags. New PR commits cancel superseded checks. Ordinary pushes to `main` do not run build CI. For a fresh preview after merging, use **Actions → Build and release → Run workflow** on `main`. Download the `AzerothFitness-v<version>` artifact; it is already an installable ZIP.

**Explicit publication:** [Publish requested version](.github/workflows/publish.yml) watches [`.github/release-request.txt`](.github/release-request.txt) on `main` and also supports manual dispatch on `main`. `none` means no release is requested. After owner approval and a Forever smoke test, prepare a PR with matching TOC/Core versions, changelog and a request such as `0.1.0-beta.1`. After squash merge the publisher repeats the shared checks, rejects existing tags, builds the ZIP, creates an annotated tag and publishes a GitHub Release. Alpha/beta requests produce prereleases; `0.1.0` produces a stable Release. Version changes must update both `AzerothFitness.toc` and `AF.VERSION` in `Core.lua`.

The tag workflow remains available for explicitly approved manual tags. A tag pushed by the publisher's default `GITHUB_TOKEN` does not trigger another workflow, so the publisher creates its release directly. Build and release setup alone does not authorize a public release.

**CurseForge:** [`.pkgmeta`](.pkgmeta) prepares the flat addon folder for native GitHub source packaging. The owner must connect this project and its tag webhook separately; no CurseForge connection or successful publication is implied. Do not add a second Actions uploader or commit author tokens. [`CURSEFORGE_DESCRIPTION.md`](CURSEFORGE_DESCRIPTION.md) is the reusable short/full listing source; the owner updates the listing manually. GitHub Release success and CurseForge availability are separate checks.
