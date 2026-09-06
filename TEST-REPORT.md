# TEST-REPORT

Living per-iteration test report, maintained per the Testing Discipline iron
rule (main repo AGENTS.md, 2026-09-06).

Layer definitions: L1 static (bash -n, shellcheck, gitleaks, no-Chinese scan),
L2 config/data validation, L3 runtime smoke, L4 host-level lifecycle. For this
documentation repository L3/L4 map to live link reachability and CI
automation behavior.

---

## 2026-09-06T20:26:23Z — commit c9c9422 (Round 2 Day 11 backfill: issue templates, ecosystem routing, zh path retirement)

**Layers executed: L1, L2. L3/L4 partially not run.**

| Check | Result |
|---|---|
| L1 bash -n + shellcheck -S warning on scripts/*.sh (4 scripts) | PASS (0 findings) |
| L1 gitleaks history scan | PASS (exit 0) |
| L1 no-Chinese content scan (CJK + fullwidth punctuation, repo-wide) | PASS |
| L1 YAML validity: 3 issue forms + tools.yaml | PASS |
| L2 generate-readme.sh --check: README.md in sync with data/tools.yaml | PASS (deterministic: consecutive runs produce no diff) |
| L2 data source schema: 69 tools, 10 categories parse | PASS |

Defects found during this development cycle (fixed pre-push or this cycle):

- The generator's default `--lang all` would have regenerated the deleted
  Chinese README - a latent no-Chinese policy violation. zh path retired;
  zh/all normalize to en (c9c9422).
- PR template checklist still required zh descriptions and README.zh.md
  regeneration; refreshed (f2f3246).
- Stale README.zh.md references in the tools.yaml header corrected.

Known issues (open): the repository has no push-triggered workflows - the
existing awesome-lint and dead-link checks run on schedule only, so template
and README changes are verified locally but not by CI on push (work-item
ledger X-AW-1).

Untested (honest boundaries):

- L3 live link reachability: validate-links.sh performs network requests and
  was not run offline-safe in this backfill cycle; the scheduled Dead Link
  Check workflow covers it periodically (last scheduled run green).
- L4 scheduled-automation behavior on the next monthly trigger not yet
  observed after the generator changes.
