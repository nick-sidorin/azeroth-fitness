# Shared standards adoption audit

Reviewed **2026-11-10** against `wow-addon-standards` **0.1.0**, commit `f36540efe61eb90671be1359849cbc6d2ddd85c1`. The source instructions and field notes were read in full. The dependency uses the same vendored-copy/lock/sync pattern as No Quest Hints Forever. It is not loaded by WoW or fetched during CI.

## Alignment and ownership

| Area | Current implementation / action | Verification boundary |
| --- | --- | --- |
| Pinned instructions | `docs/standards/AGENTS.md`, `FIELD_NOTES.md`, source SHA/version/hash lock; explicit root read instruction | Offline hash/inventory validation is not upstream authenticity; the chosen source diff was reviewed |
| Updates | Reviewed upstream tool copied to `scripts/standards.py`; explicit local-Git `sync`, never moving-ref auto-import | Tool tests cover dirty source working trees, root-profile preservation, altered documents, wrong inventory/origin and moving refs |
| CI | Shared `scripts/run_ci.sh` checks the pin before source/test/package gates; publisher uses that same entry point | Final PR-head Actions must pass; repository required-check enforcement is independently checked where access permits |
| Packaging | Exact TOC+LICENSE runtime archive; docs/scripts/tests excluded; standards exclusion tested; `.pkgmeta` excludes `docs` | Current runtime has no XML or bundled assets. XML is rejected until recursive dependency/asset support is supplied, so an incomplete XML package cannot silently pass |
| Locale/brand | Main's original EN/RU/manual selector is superseded by PR #3: 12 official locales, unchanged brand, `GetLocale()`, placeholders and fallback tests | This is pending code in the UI PR, not a claim that main already includes it or that translations were reviewed in every client |
| Native UI | PR #3 uses researched Forever portrait/inset/side-tab templates and ordinary controls | Native construction, visuals and input remain an owner preview check; no secure/gamepad inheritance or controller claim |
| Native settings | PR #3 registers one live settings form in the native AddOns category, preserving an ordinary fallback | Runtime correction belongs in PR #3; do not duplicate SavedVariables or copy No Quest Hints gameplay controls |
| Support | Copyable Issues link with localized instructions; no automatic browser opening/report submission | Runtime correction belongs in PR #3 |
| Idle performance | Motion sleeps when idle; minimap cursor tracking exists only while dragging; UI refresh timer must be created/cancelled with window visibility | PR #3 now creates/cancels the timer on show/hide |
| Persistence | Existing schema/history preserved; per-character goals/stride, account minimap preferences | Measurement/persistence audit leads in project context remain technical work; importing a standard is not evidence they are solved |
| Releases | PR+squash, full shared gates, explicit request/tag/version matching; no release requested for adoption | Public/CurseForge publication and real-client validation remain separate facts |
| Listing | Benefits-first English short/full source with separate Issues/Source links | No CurseForge project exists yet; editor/public URLs must be recorded before that release, not borrowed or invented |

## Repository enforcement observed on 2026-11-10

The active main ruleset `Protect main — PR + CI` (ID `26893445`) requires PRs, squash-only merges, resolved review threads, linear history, and disallows deletion/force pushes without bypass actors. Its `required_status_checks` rule has an **empty** `required_status_checks` list: `build` is not currently enforced. Repository settings remain owner-managed as requested; the owner must add `build` there. Agent merges still require independently verified green final-head CI. The separate branch-protection endpoint returns 403 to the integration; the public ruleset detail above was readable. No repository settings were changed.

## Conditional rules

There is no onboarding/preset modal, personal CVar effect, settings reset, native-controller implementation, shipped feature-version map or New-setting badge. Their conditional safety rules remain mandatory if introduced; importing the dependency does not authorize inventing those product features. There has been no public addon release. Metadata-based upgrade notices and an exact client/build verification record are gates for the first actual version upgrade, not claims about this unchanged-version preview.

## Review/merge order

The dependency/CI adoption is an independent PR based on main and changes no addon runtime or version. PR #3 contains the ongoing UI work and relevant runtime alignment corrections; the adoption commit has been integrated there and its combined checks must pass. Keep that preview open until the owner's native-window validation. Do not describe the runtime alignment as shipped merely because the development-only adoption is merged.
