# Azeroth Fitness — complete project and conversation handoff

> **Read this before making product or implementation decisions.**
> Snapshot: **2026-11-08**. This document captures the original product specification, follow-up decisions, research performed in the previous ChatGPT conversation, verified repository state, engineering preferences, uncertainties, and the work still outstanding. It is a *context handoff*, not evidence that a proposed feature works in the game.
> Infrastructure follow-up: **2026-11-10**, see section 16. Earlier repository/CI snapshots below are historical.
>
> **Repository:** https://github.com/nick-sidorin/azeroth-fitness  
> **Target game:** **World of Warcraft: Forever** (not generic Retail/Classic; verify compatibility against Forever specifically).  
> **Language policy:** Speak with the maintainer **in Russian**; write code, code comments, repository documentation, commit messages, pull requests, release notes and issue text **in English**. The in-game UI supports **English and Russian**.

## 1. Why this project exists

This is a third-party Lua addon for WoW: Forever that parodies Apple Fitness / Apple Health while taking a ridiculous premise seriously: the player can spend hours sitting at a real computer but complete an *in-game* step goal by walking around Azeroth.

The intended reaction after questing is something like:

> "You walked 25,000 steps, jumped 300 times, travelled 2 km sideways and burned 800 Murlocalories — without once getting out of your chair."

That is **an illustrative joke**, not a target output of the current formula.

The author/maintainer is an experienced software developer, familiar with GitHub/CI/PR workflows and with WoW addon development. He wants a real, polished, open-source addon rather than a novelty counter that misleads users. The goal is to have **trustworthy engineering wrapped in an absurdly earnest fitness-app presentation**.

**Azeroth Fitness** is the working name; it has not been declared permanent. Do not use Apple's logos, proprietary icons, art or exact visual assets. Inspiration from modern fitness UI is fine; develop a distinct, WoW-appropriate identity.

## 2. Product principles and nonnegotiable constraints

1. **Forever-first:** implement for WoW: Forever's actual addon environment, not on the assumption that Retail or Classic API behavior is identical.
2. **Measurement honesty:** clearly distinguish direct readings, inferred classifications, estimates, and fictional metrics. *No public claim of animation-accurate footstep counts.*
3. **Self-contained:** Lua plus standard permitted WoW AddOn API; no mandatory executable, web service, automation of gameplay, protected actions, or interference with the game's mechanics.
4. **Cheap when idle:** minimal CPU, memory and SavedVariables size; do not poll at full frame rate just to update a dashboard.
5. **Longitudinal:** locally persisted per-calendar-day records, resilient across sessions/reloads, with character-specific history and future account-wide aggregation.
6. **Modular:** allow additional metrics without rewriting persistence, aggregation and UI.
7. **Tasteful humor:** every extra stat should be either useful or genuinely funny; do not create dozens of noise counters.
8. **Small, intuitively understandable UI:** avoid excessive explanatory text, unnecessary labels, and clutter; tooltips may explain advanced settings. The maintainer prefers clean controls over verbose interface copy.
9. **Repository quality:** English documentation and changelog, SemVer, installer-ready ZIP releases, GitHub/CurseForge distribution, automated checks and tests.

## 3. Complete requested feature inventory

### 3.1 Steps

- Steps today, this week, this month and lifetime.
- Best single day.
- Configurable daily goal (10,000 is an example).
- Current-day progress and which historical days met their individual goals.
- Current streak of goal-meeting calendar days.
- Race-aware stride estimates. A gnome and a tauren must not be assumed to have equal footfall lengths.
- Research whether real animation footfalls are observable (so far **no established addon API for individual footfall events**). If not, estimate using world distance / stride model, adjusted for race, potentially sex/body and gait.
- Do not mislabel estimates as measurements.

### 3.2 Distances and directions

- Walking and running distance separately.
- Distance travelled backward (backpedaling).
- Sideways strafing, preferably left and right separately when technically defensible.
- Lifetime overall travel distance.
- Separately account for swimming, mounts and other travel when possible.
- Technical classification must be justified. If the signal is insufficient to know direction, use an **unknown** bucket rather than pretending all movement is forward.

### 3.3 Jumps

- Per-day, lifetime and best-day jump counts.
- Differentiate an intentional jump from falls, flight, swimming, movement effects and other vertical displacement.
- Avoid double-counting held jump input.
- Treat the selected heuristic as experimental until tested with normal and remapped input in Forever.

### 3.4 Murlocalories

- A deliberately **fictional, game-specific unit** (Russian: **мурлокалории**), separate from any real calories or actual health metrics.
- Use a transparent, stable weighted formula for distance by gait and possibly jumps/other active movement.
- **Murloc kills are a completely separate possible stat**, never part of Murlocalories. Investigate combat log, NPC identity and attribution before implementing this.

### 3.5 Interesting additional stats (only when feasible and enjoyable)

- Time spent actually moving.
- Swimming duration and distance.
- Distance mounted / by other modes.
- Single journey/session lengths.
- Personal unusual records (e.g. longest backpedal / longest strafe session).
- Possibly account-wide character comparisons in a later milestone.
- No metric bloat.

### 3.6 User interface

- A compact "today" dashboard, large step count, visible goal progress.
- Activity rings if feasible with acceptable WoW-native rendering and performance.
- 7-day and month history charts built with WoW-native UI techniques.
- Detailed stats, records and achievements view.
- Attractive but cheap animations / small celebratory feedback; no constant expensive redraw.
- Hideable main UI, minimap shortcut, and settings.
- Polished English/Russian text.
- Inspiration: clarity and polish of modern fitness apps, adapted to Azeroth, **not** a visual copy of Apple Fitness.

### 3.7 Persistence / daily records

- Save **each local calendar day**, including historical steps, jumps, distances, goals and completion.
- Restore on login and /reload; handle local midnight rollover and clock/time-zone changes sensibly and document date semantics.
- Provide yesterday / prior-week exploration, weekly and monthly totals, best day and streak.
- Use SavedVariables with a versioned schema/migrations, per-character identity; potentially account summary later.
- Avoid silently deleting or overwriting user history.

### 3.8 Achievements proposed in conversation

Seven examples have already been implemented as code-level definitions in Core.lua:

| Achievement | Definition in current code |
| --- | --- |
| Touch Grass | 10,000 lifetime estimated steps |
| Still Sitting | 50,000 estimated steps in one day |
| Backpedal Champion | 1,000 yd backward |
| Crab Mode | 10 km sideways |
| Jump Addict | 1,000 jumps |
| Azeroth Marathon | 42.195 km on foot |
| Professional Couch Adventurer | A 7-day step-goal streak |

Those are **playful starting points**, not irrevocable product requirements. More creative achievements are welcome only when grounded in observed/tracked signals.

### 3.9 Commands

- /af: open/close
- /af stats: open the statistics page
- /af settings: open settings
- Current implementation also has /af history and /af debug, and alias /azerothfitness.

## 4. Prior art: what was actually researched

### 4.1 Trailblazer

**Source:** https://github.com/Pinta365/wow-trailblazer

The prior assistant verified the public source and inspected its TOC and the following source modules:

- src/Motion.lua
- src/Strides.lua
- src/History.lua
- src/Core.lua

Its manifest at the time contained:

- Interface: 16001
- AllowLoadGameType: camelot

These values informed our initial manifest, but the **active Forever client's real compatibility still needs in-game verification**.

Conceptual findings from the inspected code:

- UnitPosition("player") world coordinates sampled around every 0.2s when awake.
- Fallback to GetUnitSpeed("player") * time for unavailable position.
- GetPlayerFacing() and planar movement vector to infer forward/back/strafe.
- Movement-triggered sampling; idle sleep.
- Guarding against huge position discontinuities/teleports and carriage on ships/trams/zeppelins.
- Separate modes for foot, swim, mount, taxi, vehicle, flight/air, shapeshift, ghost, and other travel.
- JumpOrAscendStart hook for player jump input; edge cases remain.
- Character-specific measurement history, monthly aggregation, calibration and more mature handling of cross-PC data.
- A **race + sex + gait** stride table that is significantly more detailed than ours.

Trailblazer is **more mature than our original code's motion and stride logic**. The maintainer specifically challenged whether our measurements are identical: **they are not**. Do not overstate parity.

### 4.2 Stride-length comparison and an important licensing discussion

Trailblazer's author-published example *running* stride values (as inspected in its Strides.lua):

| Body | Trailblazer | Initial Azeroth Fitness approximation |
| --- | --- | --- |
| Human male | 2.33 yards/step | 2.30 |
| Gnome male | 2.22 yards/step | 1.80 |
| Tauren male | 3.13 yards/step | 3.00 |

This difference is substantial for gnomes and will change step totals.

**Conversation conclusion:** The assistant initially claimed we could not copy any stride numbers because Trailblazer did not advertise a license. This was **too broad** and was corrected:

- Copyright generally does not protect isolated facts or measurements as such.
- A source-code implementation without an explicit license should **not** simply be copied.
- A compiled or substantial dataset may raise separate database, selection/arrangement, contractual or jurisdictional questions (especially in the EU). Do not assume that copying an entire table from an unlicensed repository is automatically permitted.
- Best practical route: **ask the Trailblazer author for permission to use the measured stride dataset in Azeroth Fitness with clear attribution and a link to the project**. If permission is granted, retain evidence, state the scope and credit it.
- Another route: independently calibrate/re-measure values; publish methodology and uncertainty.
- **Do not pretend arbitrary values are measured.** Our current defaults are explicitly coarse estimates.
- This discussion concerns **measurements/data**, which are distinct from copying source code. Avoid representing legal assessment as definitive professional advice.

The maintainer clearly wants to avoid reinventing *measured values* needlessly where a legitimate, better-established dataset exists.

### 4.3 Other addons named for research

- Dalorrian's Step Counter
- Mostly Walking
- Trailblazer
- Any other relevant WoW distance/footstep/jump tracker

The prior assistant **did not independently establish source repositories and inspect the code** for the first two. Continue research if useful; do not claim their source was read or their licensing reviewed.

## 5. Measurement model: what is measurable, inferred, estimated or fictional

| Signal / metric | Intended approach | Truthfulness classification |
| --- | --- | --- |
| Horizontal displacement | Same world/instance UnitPosition coordinates over time | Sampled measurement; can be affected by motion sampling/vehicles |
| Distance with hidden coordinates | GetUnitSpeed * elapsed while movement state is readable | Estimate |
| Individual animation footfalls | No confirmed exposed footfall API | **Not available as exact steps** |
| Steps | Distance / race, body and gait stride | Estimate, uncertainty depends on stride calibration |
| Forward/back/strafe/left/right | Facing vector vs displacement vector | Inferred only with coordinates and facing |
| Walk/run | Current speed compared to available run speed | Heuristic, must handle modifiers |
| Jump | Player input hook, followed by airborne/falling confirmation | Heuristic, validate separately |
| Swim / mount / taxi / vehicle | Relevant game state APIs | State classification, subject to compatibility |
| Murlocalories | Transparent gameplay activity weights | **Pure fiction** |
| Murloc kills | Combat log + NPC identity + attribution | **Not implemented / not verified** |

**Core safety rule:** If position, speed, facing or identity values are inaccessible/secret, do not calculate with them. Game clients may restrict values in combat or special contexts; check exact Forever APIs and handle nil/secret values before numeric operations.

**Transport nuance:** Boats/zeppelins/trams may alter player world position while character self-speed is 0. A player *walking aboard a moving ship* should ideally accumulate *their own* walking only, not ship distance. Our current conservative implementation discards ambiguous intervals rather than giving phantom steps, but can undercount legitimate onboard walking. Trailblazer handles this more carefully.

**Teleport nuance:** Discard discontinuities after teleports, hearths, loading screens, instance transition, continent change, large world snaps and over-long sample intervals. Avoid adding arbitrary distance when coordinates are absent and speed is also unreadable.

**Direction nuance:** With speed fallback alone, strafe cannot be reliably distinguished from forward run; category must remain unknown. Revisit left/right vector orientation in the actual client.

## 6. Current repo state — verified via connected GitHub on 2026-11-08

The connected GitHub repository was read directly. At that checkpoint:

- Public repository: nick-sidorin/azeroth-fitness.
- Default branch: **main**.
- Root contained: AzerothFitness.toc, Bootstrap.lua, Core.lua, Motion.lua, Jump.lua, UI.lua, Locale.lua, README.md, CHANGELOG.md, LICENSE, .gitignore, .github/workflows/release.yml and docs/RESEARCH.md.
- Manifest version: **0.1.0**, interface **16001**, AllowLoadGameType **camelot**, SavedVariables **AzerothFitnessDB**.
- GitHub had **no published releases, no PRs, and no issues** in the fetched API response at that checkpoint.
- The current implementation is **experimental and not verified in a running Forever client**. Do not call it gameplay-tested, production-ready, or released.
- CI workflow currently packages an addon ZIP on manual dispatch or v* tag, checks presence of files/manifest and uses luac5.1 -p to parse syntax. There is **no dedicated PR test workflow** or automated gameplay API test harness yet.
- MIT LICENSE exists for the code **we authored**, not for unlicensed external material.

**Important:** These are a dated snapshot, not a guarantee of current status. When Codex begins, fetch the repository, current branches, PRs, issues, and releases again. Use **live repository state** over memory or this document wherever they disagree.

## 7. Current architecture and source file responsibilities

**AzerothFitness.toc** — addon metadata and load order:
Locale.lua -> Core.lua -> Motion.lua -> Jump.lua -> UI.lua -> Bootstrap.lua.

**Locale.lua**
- Central string dictionaries (EN/RU).
- AF:T(key) uses db.language = auto/en/ru; auto checks GetLocale().

**Core.lua**
- Data model, daily date keys, character storage, rolling aggregates, streaks, best day, achievement predicates, step calculations and fictional calories.
- Schema constant **1**, but no mature migration layer yet.
- AF.METERS_PER_YARD = **0.9144**.
- AF.STRIDE_YARDS has one coarse **running** stride per race, currently HUMAN 2.30, DWARF 2.25, NIGHTELF 2.30, GNOME 1.80, ORC 2.35, SCOURGE 2.25, TAUREN 3.00, TROLL 2.50, SKYBORNE 2.30.
- Per-character stride override is a single number. Walking uses 0.55 * run stride; back uses 0.68 * run stride; side movement inherits walk/run cadence depending on speed.
- **No sex/body-specific table and no real gait calibration workflow yet**.

**Motion.lua**
- Motion sampler wakes on movement / relevant vehicle events.
- SAMPLE_PERIOD 0.20 s; MAX_INTERVAL 0.8 s; teleport cutoff 65 yards/s; carried margin 2 yards/s; side threshold absolute forward projection <= 0.50.
- UnitPosition coordinate deltas (same area/instance) if readable, else GetUnitSpeed fallback, else no distance.
- Uses facing dot product for back/left/right, speed ratio to classify forward walk/run.
- Excludes ghost, air, several animal forms; categorizes swim/mount/transport separately.
- Suspiciously carrier-influenced intervals are dropped.
- Probe for /af debug (mode, source, direction, speed).

**Jump.lua**
- Secure hooks JumpOrAscendStart if available.
- Opens a short pending confirmation window (0.8 seconds) and checks IsFalling.
- Ignores mounts, swimming, flying, ghost and vehicle; debounce at least 0.35 seconds.
- This is NOT equivalent to guaranteed jump animation events; alternative bindings and edge cases must be tested.

**UI.lua**
- Native movable 520 x 570 frame, tabs for today/history/records/settings.
- Today: large steps, goal bar, jumps, Murlocalories, total foot distance, run/walk subtotals, position-vs-speed coverage.
- History: 7/30-day rolling bar chart made with native textures; not yet true calendar-aligned week/month.
- Records: best day, streak, lifetime and 7 achievement labels.
- Settings: daily step goal, running stride override, language.
- Fixed minimap shortcut; DB has showMinimap field but no polished user-facing toggle.
- UI refresh roughly once per second only while visible.

**Bootstrap.lua**
- ADDON_LOADED / PLAYER_LOGIN initialization; slash registration.

**.github/workflows/release.yml**
- Manual/tag-triggered validation, Lua 5.1 parser check, zipped addon directory, workflow artifact, and prerelease creation for v* tags.

**docs/RESEARCH.md**
- Short research summary; retain and update when actual API tests provide new evidence.

## 8. Existing persistence design and future migration needs

The current account-level SavedVariables object is named **AzerothFitnessDB**, conceptually:

    AzerothFitnessDB = {
      schema = 1,
      language = "auto",          -- auto, en, ru
      showMinimap = true,
      characters = {
        ["<UnitGUID>"] = {
          name = "...",
          goal = 10000,
          stride = nil,           -- optional running yd/step override
          days = {
            ["YYYY-MM-DD"] = {
              steps = 0,          -- fractional internally; rounded on display
              jumps = 0,
              murlos = 0,
              yards = { run = 0, walk = 0, back = 0,
                strafeLeft = 0, strafeRight = 0, unknown = 0,
                swim = 0, mount = 0, transport = 0 },
              moveSeconds = 0,
              coverage = { position = 0, speed = 0 },
              goal = 10000       -- goal frozen per day
            }
          },
          total = { steps = 0, jumps = 0, murlos = 0,
            yards = {}, moveSeconds = 0,
            coverage = { position = 0, speed = 0 } },
          achievements = { touchGrass = "YYYY-MM-DD", ... }
        }
      }
    }

Notes:
- This is illustrative: many buckets are lazily created rather than preinitialized.
- Current history retains daily entries indefinitely; future retention/compaction needs explicit policy.
- The current weekly/monthly numbers are rolling 7/30-day aggregates, not aligned to ISO week/calendar month; original spec requested calendar week/month. Discuss or implement both appropriately.
- Days use the client's local date(), not server reset; when changing time zone, historical date keys are not retroactively transformed.
- A day's goal is stored alongside the daily activity, and changing the goal updates today's target but not prior-day targets.
- Lifetime totals and daily records must remain consistent. Implement tests for transitions, serialization, schema upgrades and potential double-counting.
- Character identity is UnitGUID, intended to survive renaming. Future account-level aggregate is out of MVP scope.
- Do **not** discard existing SavedVariables during migrations or debugging without explicit user consent.

## 9. Current Murlocalorie formula

The initial formula is designed for fun, not physiological realism. It is currently implemented in Core.lua.

| Action | Fictional Murlocalories |
| --- | --- |
| 100 yd walking | 1.2 |
| 100 yd running | 1.8 |
| 100 yd moving backward | 2.2 |
| 100 yd strafing left or right | 2.4 |
| 100 yd with unknown direction | 1.8 |
| 100 yd swimming | 2.0 |
| Confirmed jump | 0.75 |
| Mount or transport | 0 |

Formula: sum(distance_in_yards_for_gait / 100 * gait_weight) + (confirmed_jumps * 0.75). These values are provisional game-design coefficients. Murloc kill counting is explicitly unrelated.

## 10. MVP vs full vision

### Currently written in source (NOT confirmed in-game)

- Basic persistence, per-character/daily records, goal and streak logic.
- Basic coordinate/speed movement sampling, run/walk/back/strafe classification, unknown bucket.
- Basic jump confirmation heuristic.
- Basic Murlocalories and achievements.
- Basic EN/RU dashboard/history/records/settings, minimap shortcut, commands.
- Manual/tag release packaging workflow.

### Missing / partial / should not be claimed complete

- Live WoW Forever API and UX compatibility tests.
- Genuine race + sex + gait calibrated stride model; empirical dataset permission.
- Robust transport motion subtraction; handling of moving boats, fall/knockback transitions.
- Dedicated separate detailed history for jump records and gait records in the UI.
- Calendar-aligned week/month in addition to rolling ranges.
- Detailed movement breakdown (including sideways and back distance) visibly exposed in the UI.
- Best *jump* day and other richer records.
- Explicit goal-met calendar markings and longer history navigation.
- Activity rings, polished typography/animation, better resizing, minimap positioning and settings.
- Optional character/account comparison, advanced modes and journeys.
- Combat-log-verified murloc kill counts.
- Thorough data migrations, automated edge-case tests, Lua/WoW mock harness and CI required checks for PRs.
- Versioned public GitHub release and CurseForge publication.

## 11. Potential implementation defects / audit leads

These are **questions for code review and test design**, not proven in-game bug reports:

1. **Direction sign/orientation:** verify left/right strafe vectors empirically; a comment says x/north and y/west, which needs direct validation.
2. **Mode sequencing:** player movement sampled across a jump or dismount may be misclassified because the mode is observed at sample end; design integration tests.
3. **Mounted / swimming / shapeshift and ghost edge cases:** ensure no phantom steps from state transition drift.
4. **Carrier suppression:** current detector can discard legitimate walking on moving vehicles; distinguish relative self-motion where possible.
5. **Jump coverage:** input hook may miss remapped jump or keyboard behavior; confirmation window is sensitive to timing.
6. **Clock transitions and streak math:** midnight/DST/time-zone change, absence of history and changing goals.
7. **Combat/secret-value safety:** do not call math/string operations on secret values; verify API behavior in Forever.
8. **SavedVariables schema:** existing objects may lack new nested fields after an upgrade; migration routines should fill robustly.
9. **UI layout:** test both locales, all UI scales, Escape behavior, tabs and bar chart scaling.
10. **Achievement cost:** checking all achievements for each movement sample and rescanning day history could be avoided/optimized.
11. **Movement time semantics:** moveSeconds currently accumulates each recorded segment; no special quality split or pause semantics.
12. **No PR CI:** syntax-check action runs on workflow_dispatch/tags but not automatically on every PR. Add branch protection required checks once reliably configured.
13. **Release state:** do not create public release tags until after credible QA and user approval.

## 12. Required in-client QA checklist

At minimum reproduce and record results in Forever:

- Fresh install / reload / logout / login / per-character persistence.
- Stand still; walk forward; run; slow walk toggle; run with speed modifiers; sprint.
- Backpedal; strafe left; strafe right; diagonal movement.
- Jump once; repeated jumps; hold jump; falling from cliff; swimming; mount jumping; flying.
- Mount/dismount, taxi, vehicle, transport, boat/zeppelin/tram; walking while carried.
- Teleport, hearth, portal, loading screen, zone/instance boundary, rapid world snapping.
- Dungeons/interiors where UnitPosition may be inaccessible.
- Combat and restricted/secret values.
- Midnight date change; DST/time-zone changes and goal changes.
- Human/gnome/tauren and other races/sexes with calibration experiments.
- RU/EN locale and different UI scales.
- Performance: standing idle, several hours of movement, long-term SavedVariables growth.
- Clean no-error load (with Lua error reporting enabled), correct ZIP packaging.

Record the exact game build/API output when possible; use reproducible test cases, not guesswork. **Do not upgrade experiment status to verified solely based on static analysis or competitor code.**

## 13. Development practices requested by maintainer

The maintainer has already built other WoW addons and prefers a conventional professional GitHub workflow:

- Work on feature branches; **pull request into main**, not direct commits to main.
- **Squash merge** PRs for clean history.
- Required CI checks for PRs to catch Lua syntax/test/build failures; avoid merges on red CI.
- Set branch protection / rulesets once support and permissions allow; distinguish settings requested from settings actually applied.
- Keep README/CHANGELOG and any release descriptions up to date; maintain a reusable Markdown source for descriptions instead of recreating text each release.
- Keep commit history and PR bodies clear but succinct; the UI should avoid explanatory noise.
- Use English for repo artifacts; discuss tradeoffs and updates in Russian.
- Scope work independently; do research and implement without repetitive questions, but flag decisions that affect behavior, licensing or data integrity.
- Open-source hygiene: version numbers, zip folder name, no unwanted dependencies, attribution, safe tests, no automatic untested public releases.
- When publishing a new release, provide the updated description/changelog immediately.

These are **preferences/requirements to implement and verify**, not evidence the repository already enforces branch protections. At the 2026-11-08 GitHub checkpoint, this repo did not have PR checks already configured.

## 14. Suggested next steps for Codex

1. **Re-inspect current branch/main/repo files** and read this document, AGENTS.md, README.md and docs/RESEARCH.md.
2. Perform a static compatibility and correctness audit; identify genuinely broken code paths, verify Lua 5.1 parsing and implement a mock-based test harness where useful.
3. Create automatic PR CI for Lua syntax, tests and installable archive validation, then propose/verify main protection and squash-only workflow.
4. Improve the movement engine with well-defined modes and quality flags; test or develop a small in-game diagnostics mode for API observations.
5. Fix or validate jump counting and direction classification with in-client test instructions for the maintainer.
6. Make stride calibration race/sex/gait aware. Investigate permission to use Trailblazer's empirical table; do not silently copy full third-party code/data.
7. Improve saved history/aggregation, migration tests, and detail screens without bloating MVP.
8. Improve visual polish after metrics pass QA. Rings are desirable, not worth broken performance.
9. Once owner has tested behavior in Forever, prepare a proper versioned prerelease/CurseForge release.

### Suggested first Codex prompt

"Read AGENTS.md and docs/PROJECT_CONTEXT.md end to end, then inspect the repository rather than assuming this document is up to date. We are building Azeroth Fitness for WoW: Forever. Start by auditing the existing v0.1.0 implementation for API compatibility, measurement bugs, persistence issues and missing PR CI. Propose a prioritized plan and implement the highest-impact safe fixes on a feature branch with tests and a PR. Speak to me in Russian; write repo artifacts in English; never silently copy unlicensed third-party code or claim unverified measurements are exact."

## 15. External links and background

- **Our repository:** https://github.com/nick-sidorin/azeroth-fitness
- **Trailblazer reference:** https://github.com/Pinta365/wow-trailblazer
- **Repo README:** ../README.md
- **Prior research summary:** RESEARCH.md
- **Changelog:** ../CHANGELOG.md
- **CI package workflow:** ../.github/workflows/release.yml

This file is intended to preserve the full product and decision context when moving from an ordinary ChatGPT conversation into a new Codex conversation. It should evolve as **decisions are actually made**: mark proposals separately from validated behavior, update the status after tests/releases, and avoid rewriting historical facts.

## 16. Build and release process alignment — 2026-11-10

The owner requested the same build/release process as `nick-sidorin/no-quest-hints-forever` and a preview of the current addon. The owner will copy repository settings manually. This request does not include a public release or runtime fixes.

Implemented in source:

- `release.yml`: PR checks named `build`, manual previews, tag builds and tag releases; ordinary main pushes do not run build CI. PR updates cancel superseded runs. Preview artifacts contain the addon folder directly, not a nested ZIP.
- `scripts/run_ci.sh`: shared Lua 5.1 parser, discovered mocked regression suites, TOC integrity and Python packaging tests. `scripts/package_addon.py`: deterministic TOC-plus-LICENSE archive with exact source-byte verification. Root runtime files retain their original layout in Git; archives use `AzerothFitness/`.
- `publish.yml`: explicit version request on main, full repeated CI, version/changelog/tag gates, annotated tag and GitHub Release. Stable and alpha/beta requests follow the reference process. `.github/release-request.txt` is `none`, preventing publication when this infrastructure is installed.
- `.pkgmeta` and `CURSEFORGE_DESCRIPTION.md`: preparation for native CurseForge source packaging and manually maintained listing copy. No CurseForge connection or publication has been verified.

Local validation: Lua 5.1 parsing and three mocked accounting/motion/jump suites passed, along with nine packaging tests. These tests establish selected code behavior, not Forever compatibility. Check the live PR/Actions result for remote validation and merge state.

Addon runtime remains the experimental 0.1.0 baseline, with schema 1 unchanged. No live Forever QA or public release was performed for this infrastructure change. The earlier audit's state-transition, unavailable-speed and incomplete-ledger concerns remain follow-up work. Next priorities remain measurement correctness, persistence robustness and in-client diagnostics before UI polish.

## 17. Owner-requested native UI preview — 2026-11-10

The owner tested the original dashboard and supplied screenshots: the flat custom styling felt foreign to WoW, Russian text appeared as boxes, and the shortcut was a rectangular rune. The owner requested original Blizzard components, Overlord-inspired dark/gold framing, and a playful Fitness-style activity dashboard. Horizontal bars are explicitly acceptable for this iteration; circular rings are deferred. Do not copy Overlord's art or Apple assets.

Implemented in the preview branch (verify the live PR/Actions for its current state):

- Ordinary `BackdropTemplate` dialogs with Blizzard dark backgrounds/gold borders, `UIPanelButtonTemplate`, `UIPanelCloseButton`, native checkboxes/edit boxes and `StatusBar` textures. Font sizing derives from `GameFontHighlight:GetFont()` rather than a hardcoded Latin font file. Achievements also have English/Russian UI text. Actual client typography is still unverified.
- Three horizontal progress bars: estimated steps, jumps and fictional Murlocalories. Default targets are 10,000 / 100 / 300. `char.activityGoals` and `day.activityGoals` add jump/Murlocalorie targets without a schema break; existing `char.goal`/`day.goal` remain the step targets. Saving validates all targets before applying them, updates today only, and preserves previous recorded targets. Old history is not backfilled with invented additional targets. Step streak/achievement semantics are unchanged.
- `Minimap.lua` owns a circular masked Blizzard Sprint icon and tracking border. Left click toggles the window, right click opens settings, and dragging follows the minimap perimeter using scale-correct cursor coordinates. `db.minimapAngle` persists its account-wide angle; the existing `db.showMinimap` gains a checkbox. Cursor polling exists only while dragging. The TOC addon-list icon also uses Sprint.
- Escape closes the window, its header drags it, and opening fits its scale to the available UI dimensions. History and record views refresh only when selected.

Validation: the shared Lua 5.1 gate includes new UI-interaction, minimap-drag and additive goal-upgrade tests, alongside prior movement/accounting and ZIP tests. Mocks cannot verify appearance, Russian glyph rendering, texture availability or client interaction. Hand over the PR's single installable ZIP for owner QA before merging this UI change. No release, tag or version bump is requested.

Client checklist: install preview and `/reload`; ruRU text without boxes; EN/RU switching; all four tabs; saving each goal and invalid input; yesterday's records unchanged; Escape/close/header drag; circular shortcut, four drag quadrants, reload and minimap/UI scale changes; hide/re-show shortcut via `/af settings`; no window toggle on drag release. Confirm the style against the supplied Overlord reference. Rings and original custom decorative artwork remain later design iterations.

## 18. Brand, automatic localization and textured ledger — 2026-11-10

Owner feedback on the #3 preview confirms that the Russian labels are now readable in the supplied client screenshot and that the direction is promising. The screenshot also shows the game world through the main window and activity panels. The owner requested a visible texture instead of translucency and a more polished Overlord-inspired design. This is feedback on the supplied scenario, not blanket approval of all UI or measurement behavior.

Decisions superseding earlier language/design notes:

- The brand is **Azeroth Fitness** in all locales, not a translated Russian name. No translated TOC title, minimap label or window title.
- Language comes from `GetLocale()` only. Remove the language buttons and ignore legacy `db.language`. Support all 12 official WoW locales with complete dictionaries, shared enUS/enGB and esES/esMX translations, and English fallback. Use the neighboring No Quest Hints Forever project as the engineering reference. The owner plans a shared guideline there; do not treat it as already available or copy unrelated gameplay policies.
- Use a genuinely opaque base with tiled native marble, muted gold/brass framing, a framed emblem header, real Blizzard top tabs and distinct typography for current values and targets. See `docs/UI_DESIGN.md`. Do not copy Overlord/Apple art. Rings remain deferred.

Implemented in the updated #3 branch: `LocaleTranslations.lua` loads second, before consumers; complete translation/placeholder/brand checks; localized numeric separators/units; decimal-comma stride input; opaque surfaces and native tabs. The screenshot's 29-jumps/28% rounding error is also covered by a focused regression. Existing activity/goal schema stays compatible. No release, merge approval or universal client validation is implied. Check the latest PR head and Actions artifact rather than reusing the earlier build link.
