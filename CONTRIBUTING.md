# Contributing to Awesome VPS

Thanks for your interest in contributing! This is a community-curated list of VPS tools and resources.

## How to Add a Tool

The tool list is generated from a single YAML data source: **`data/tools.yaml`**. Do not edit `README.md` or `README.zh.md` directly — they are generated.

1. **Fork** this repository
2. **Add the tool** to `data/tools.yaml` under the appropriate category
3. **Regenerate** the READMEs: `./scripts/generate-readme.sh --lang all`
4. **Validate** links: `./scripts/validate-links.sh`
5. **Submit a pull request** (commit `data/tools.yaml` together with the regenerated `README.md` / `README.zh.md`)

## Entry Format (YAML)

```yaml
- name: Tool Name            # string, or {en: ..., zh: ...} when the name differs per language
  url: https://github.com/user/repo
  category: deployment        # one of the category ids defined at the top of data/tools.yaml
  language: Go                # primary implementation language (omit for ecosystem entries)
  activity_status: active     # active | maintained | stagnant | archived
  description:
    en: "One-line description of what it does."
    zh: "一句话描述它的功能。"
```

The `activity_status` field maps to an **activity marker** (see below). Use `active` for new entries; `scripts/update-metadata.sh` will correct it on the next run based on the repo's real activity.

### Fields

| Field | Requirement | Example |
|---|---|---|
| **name** | Display name (string or `{en, zh}`) | `Ollama` or `{en: Nezha, zh: 哪吒探针}` |
| **url** | Canonical link to the official repo or website | `https://github.com/ollama/ollama` |
| **description** | `{en, zh}` one sentence each, original wording | `en: Run Llama, Mistral, Phi locally.` |
| **category** | One of the category ids in `data/tools.yaml` | `deployment` |
| **language** | Primary implementation language (optional) | `Go`, `Shell`, `Python` |
| **activity_status** | One of active / maintained / stagnant / archived | `active` |

### Activity Markers

Activity markers reflect the health of the tool's source repository, not its difficulty:

- 🟢 **Active** — commit within the last 6 months
- 🟡 **Maintained** — commit within the last 6–12 months
- 🔴 **Stagnant** — no commit in 12+ months
- ⚫ **Archived** — repository is archived/read-only

Markers are refreshed automatically by `scripts/update-metadata.sh` (GitHub API), which rewrites `activity_status` in `data/tools.yaml`. Tools that become 🔴 or ⚫ are moved to the **Archived / Historical** section.

## Guidelines

### Must

- ✅ Tool is **open-source** (or has a free self-hostable tier)
- ✅ Tool is **actively maintained** (commit within last 12 months) — otherwise note it in the Archived / Historical section
- ✅ Description is **original** — write it in your own words
- ✅ Tool is placed in the **correct category**
- ✅ Both `en` and `zh` descriptions are provided
- ✅ Each category keeps **3–15 tools**; split or merge categories if needed

### Must Not

- ❌ Don't edit `README.md` / `README.zh.md` directly — edit `data/tools.yaml` and regenerate
- ❌ Don't copy descriptions from the tool's README or website
- ❌ Don't add duplicate tools (search first)
- ❌ Don't add tools that are abandoned or unmaintained
- ❌ Don't add commercial-only / closed-source tools
- ❌ Don't use affiliate links

## Categories

| Category id | What belongs here |
|---|---|
| `init` | First-run setup scripts, system init tools |
| `hardening` | SSH hardening, firewall, intrusion prevention, fail2ban/CrowdSec |
| `network` | Reverse proxy, SSL, tunneling, DDNS, VPN, CDN |
| `deployment` | Docker orchestration, PaaS, app stores, compose collections |
| `monitoring` | Uptime monitoring, server metrics, status pages |
| `backup` | Backup tools, backup strategies, restore tools |
| `ai` | LLM runtimes, AI frontends, RAG, vector DBs |
| `audit` | Security auditing, vulnerability scanning, compliance checking |
| `archived` | Historical / archived tools kept for reference |
| `ecosystem` | 0x10debug account repos that form the VPS toolchain |

## Reporting Issues

- **Broken link** — open an issue with `[Broken Link]` in the title, or run `./scripts/validate-links.sh`
- **Miscategorized tool** — open an issue suggesting the correct category
- **Outdated tool** — open an issue if a tool is no longer maintained; it should move to Archived / Historical

## Scripts

- `scripts/generate-readme.sh` — render `README.md` / `README.zh.md` from `data/tools.yaml` (`--lang en|zh|all`; `--check` to verify no drift).
- `scripts/update-metadata.sh` — refresh `activity_status` in `data/tools.yaml` from the GitHub API (`--check` to report, `--update` to rewrite). Requires `gh auth` or `GITHUB_TOKEN`.
- `scripts/validate-links.sh` — verify all README links are reachable (`--timeout SECONDS`). Exits 1 on broken links.
- `scripts/check-links.sh` — legacy link checker.

## CI

Pull requests are checked by `.github/workflows/awesome-lint.yml`:

- **awesome-lint** — README format compliance (sindresorhus/awesome-lint)
- **YAML sync** — `generate-readme.sh --check` (READMEs must match `data/tools.yaml`)
- **Metadata** — `update-metadata.sh --check` (activity markers must be fresh)

Dead links are checked weekly by `.github/workflows/dead-links.yml`, and activity markers are refreshed monthly by `.github/workflows/update-metadata.yml` (which opens a PR with the changes).

## Questions?

Open an issue with the `question` label. We're happy to help.
