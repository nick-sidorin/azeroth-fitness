# Agent instructions — Azeroth Fitness

This is the repository for **Azeroth Fitness**, a humorous but technically serious activity-tracking addon for **World of Warcraft: Forever**.

## Read first

1. **[docs/PROJECT_CONTEXT.md](docs/PROJECT_CONTEXT.md)** — **complete product vision, prior conversation decisions, technical research, source architecture, limitations, licensing discussion, current state and Codex handoff**. Treat this as mandatory context before choosing work.
2. [README.md](README.md) — public feature description, installation and caveats.
3. [docs/RESEARCH.md](docs/RESEARCH.md) — condensed original research, including Trailblazer comparison.
4. Inspect current code, live GitHub issues/PRs and Forever API evidence. **Git and verified tests override dated documentation.**

## Communication and engineering conventions

- Talk with the maintainer in **Russian**.
- Write code, comments, repository Markdown, commits, pull requests, changelog and release notes in **English**.
- Support **ruRU and enUS** user-facing addon locale.
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

## Build and release workflow

- Run `bash scripts/run_ci.sh` with Python 3.9+, `lua5.1` and `luac5.1`. Add regression tests for behavior changes. Use `scripts/package_addon.py` for ZIPs; the TOC plus LICENSE defines installable contents.
- Follow the No Quest Hints Forever process: PR checks named `build`, manual previews, squash merge, and a separate explicit release request. Ordinary main pushes do not run build CI. The owner manages repository settings; do not claim required checks are enforced without inspecting them.
- Give the owner a direct GitHub Actions artifact link for previews. Artifact downloads must contain `AzerothFitness/` immediately, without another ZIP inside. Keep preview versions unchanged unless a release is requested.
- `.github/release-request.txt` starts at `none`. Change it to a version, bump TOC/Core versions, or create tags only for an owner-requested release after Forever QA. The publisher reuses the full CI gate; alpha/beta suffixes mark prereleases.
- Keep `CHANGELOG.md` and `CURSEFORGE_DESCRIPTION.md` current for user-facing releases. `.pkgmeta` supports native CurseForge source packaging once the owner connects the project/webhook; do not add another uploader or assume that GitHub publication proves CurseForge availability.
