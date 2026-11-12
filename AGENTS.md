# Agent instructions — Azeroth Fitness

## Shared development dependency

Before substantive work, read [the pinned shared standards](docs/standards/AGENTS.md) and [their field notes](docs/standards/FIELD_NOTES.md), then this project profile and [docs/PROJECT_CONTEXT.md](docs/PROJECT_CONTEXT.md). The [lock file](docs/standards/standards.lock.json) records the exact reviewed upstream commit, version and hashes. These are development instructions, excluded from the addon package. Follow the [adoption/update procedure](docs/standards/README.md); run `python3 scripts/standards.py check` offline. Owner policy: requested upstream standards edits may be squash-merged after green PR checks without another confirmation, then adopted here from the merged main commit. At the start of addon work, check upstream main for newer standards and review/adopt the complete update without another confirmation. Keep the exact commit/hash lock; do not execute moving remote instructions or cherry-pick individual rules. This authorization does not merge gameplay/UI previews or publish addon releases. Current owner instructions and local product rules refine the shared baseline.

This is the repository for **Azeroth Fitness**, a humorous but technically serious activity-tracking addon for **World of Warcraft: Forever**.

## Read first

1. **[docs/PROJECT_CONTEXT.md](docs/PROJECT_CONTEXT.md)** — **complete product vision, prior conversation decisions, technical research, source architecture, limitations, licensing discussion, current state and Codex handoff**. Treat this as mandatory context before choosing work.
2. [README.md](README.md) — public feature description, installation and caveats.
3. [docs/RESEARCH.md](docs/RESEARCH.md) — condensed original research, including Trailblazer comparison.
4. Inspect current code, live GitHub issues/PRs and Forever API evidence. **Git and verified tests override dated documentation.**

## Communication and engineering conventions

- Talk with the maintainer in **Russian**.
- Write code, comments, repository Markdown, commits, pull requests, changelog and release notes in **English**.
- Keep **Azeroth Fitness** untranslated in every locale. Follow `GetLocale()` automatically; do not add language-selection controls or honor legacy `db.language` overrides.
- Support all official client locales: **enUS, enGB, ruRU, deDE, frFR, esES, esMX, itIT, ptBR, koKR, zhCN, zhTW**, with English fallback. Follow the neighboring No Quest Hints Forever patterns where applicable; the pinned shared guidance defines the baseline.
- Use **feature branch -> pull request -> squash merge**; never push directly to main.
- Add meaningful automated Lua 5.1 parsing, tests and archive checks; require green checks before merges where branch settings permit.
- Keep README, changelog, relevant decisions and release descriptions synchronized with real changes. Prefer concise comments and uncluttered UI.
- Never claim a feature works in **Forever** without validation. Do not confuse generic WoW/Classic API notes with this client's behavior.
- Never present **step estimates** as literal animation footfalls. Show uncertainty where distance/speed/direction is inferred. Murlocalories are fictional.
- Do not copy Trailblazer code or bulk stride tables without compatible permission/license; using uncopyrightable factual measurements and independent algorithms is a separate question. Credit prior art.
- Never automate gameplay or require external processes. Respect performance, restricted/secret API values and SavedVariables compatibility.
- Avoid large rewrites or schema breaks without migration and tests. Preserve user data.
- Do not create public release tags or publish to CurseForge before in-game QA and explicit owner approval.

## Immediate focus

The existing **v0.1.0** code is an unverified experimental baseline. First inspect it; prioritize API correctness, measurement accuracy, persistence and testing/PR CI over visual effects. Read docs/PROJECT_CONTEXT.md for the complete prioritized roadmap and original product request.

## Maintaining context

Update docs/PROJECT_CONTEXT.md when a major technical/product decision is validated. Clearly separate **requested**, **implemented in source**, **verified in game**, and **released** status so a future Codex session can continue without relying on chat memory.

For interface work, read [docs/UI_DESIGN.md](docs/UI_DESIGN.md). Use opaque textured native surfaces and original client controls; do not copy the Overlord reference's artwork or introduce secure/glue templates on the assumption that template registration permits addon use.

## Build and release workflow

- Run `bash scripts/run_ci.sh` with Python 3.9+, `lua5.1` and `luac5.1`. Add regression tests for behavior changes. Use `scripts/package_addon.py` for ZIPs; the TOC plus LICENSE defines installable contents.
- Follow the No Quest Hints Forever process: PR checks named `build`, manual previews, squash merge, and a separate explicit release request. Ordinary main pushes do not run build CI. The owner manages repository settings; do not claim required checks are enforced without inspecting them.
- Give the owner a direct GitHub Actions artifact link for previews. Artifact downloads must contain `AzerothFitness/` immediately, without another ZIP inside. Keep preview versions unchanged unless a release is requested.
- `.github/release-request.txt` starts at `none`. Change it to a version, bump TOC/Core versions, or create tags only for an owner-requested release after Forever QA. The publisher reuses the full CI gate; alpha/beta suffixes mark prereleases.
- Keep `CHANGELOG.md` and `CURSEFORGE_DESCRIPTION.md` current for user-facing releases. `.pkgmeta` supports native CurseForge source packaging once the owner connects the project/webhook; do not add another uploader or assume that GitHub publication proves CurseForge availability.

## Project profile and release boundaries

- Target: WoW: Forever / Camelot; TOC Interface 16001; Lua 5.1. Exact owner client build is not yet recorded. Interface metadata is not compatibility proof.
- Runtime layout: root Lua modules and `AzerothFitness.toc`; packaged root is `AzerothFitness/`. No runtime XML or bundled texture/font assets exist. Referenced Blizzard art stays in the client. Add an XML dependency/asset-inventory gate before introducing either.
- State: account-level `AzerothFitnessDB`; GUID-keyed character activity, daily history and lifetime totals. Local calendar dates, no automatic retention/deletion, preserve old data on upgrades. Minimap preferences are account-wide; goals/stride are per character.
- Commands: `/af`, `/af stats`, `/af history`, `/af settings`, `/af debug`, temporary `/af reset` (native confirmation; current-character statistics only). Native category: Azeroth Fitness, with one shared fallback form, localized copyable support URL and visible-only refresh. Portrait/settings changes in PR #3 were owner-approved and squash-merged. The achievements iteration remains a separate preview until client QA. No onboarding modal, personal CVar manipulation or controller navigation exists.
- Source: https://github.com/nick-sidorin/azeroth-fitness; Issues: https://github.com/nick-sidorin/azeroth-fitness/issues.
- CurseForge project, public URL and description-editor URL are not configured. Do not copy another project's ID or claim publication. Record the owner's actual URLs before a CurseForge release.
- CI entry point: `bash scripts/run_ci.sh`; check name `build`; package with `python3 scripts/package_addon.py dist/AzerothFitness-v0.1.0.zip`. Repository settings remain owner-managed; verify enforcement separately from a passing run.
- Publisher: `.github/workflows/publish.yml`; request `.github/release-request.txt`, currently `none`; `vX.Y.Z` tags with optional alpha/beta suffix. Stable/CurseForge release requires owner approval and matching client QA.
- Before the first real version upgrade, implement/test metadata-based post-load notices. Feature introduction/New-setting bookkeeping applies only when those features ship; do not invent them during a documentation dependency import.
- See [the standards alignment audit](docs/STANDARDS_ALIGNMENT.md) and [release handoff template](docs/RELEASE_HANDOFF.md). Keep vendored standards unchanged; project decisions belong here.
