# Contributing to Awesome VPS

Thanks for your interest in contributing! This is a community-curated list of VPS tools and resources.

## How to Add a Tool

1. **Fork** this repository
2. **Add the tool** to the appropriate category in **both** `README.md` (English) and `README.zh.md` (Chinese)
3. **Follow the entry format** (see below)
4. **Submit a pull request**

## Entry Format

```markdown
- 🟢 [Tool Name](https://github.com/user/repo) - One-line description of what it does. `Language`
```

The leading emoji is an **activity marker** (see below). Use 🟢 for new entries; `scripts/update-metadata.sh` will correct it on the next run based on the repo's real activity.

### Fields

| Field | Requirement | Example |
|---|---|---|
| **Activity marker** | One of 🟢 🟡 🔴 ⚫ (see levels below) | `🟢` |
| **Name** | Link to the official repo or website | `[Ollama](https://github.com/ollama/ollama)` |
| **Description** | One sentence, original wording (don't copy the tool's README) | `Run Llama, Mistral, Phi locally.` |
| **Language** | Primary implementation language | `` `Go` ``, `` `Shell` ``, `` `Python` `` |

### Activity Markers

Activity markers reflect the health of the tool's source repository, not its difficulty:

- 🟢 **Active** — commit within the last 6 months
- 🟡 **Maintained** — commit within the last 6–12 months
- 🔴 **Stagnant** — no commit in 12+ months
- ⚫ **Archived** — repository is archived/read-only

Markers are refreshed automatically by `scripts/update-metadata.sh` (GitHub API). Tools that become 🔴 or ⚫ are moved to the **Archived / Historical** section.

## Guidelines

### Must

- ✅ Tool is **open-source** (or has a free self-hostable tier)
- ✅ Tool is **actively maintained** (commit within last 12 months) — otherwise note it in the Archived / Historical section
- ✅ Description is **original** — write it in your own words
- ✅ Tool is placed in the **correct category**
- ✅ Entry added to **both** English and Chinese READMEs
- ✅ Each category keeps **3–15 tools**; split or merge categories if needed

### Must Not

- ❌ Don't copy descriptions from the tool's README or website
- ❌ Don't add duplicate tools (search first)
- ❌ Don't add tools that are abandoned or unmaintained
- ❌ Don't add commercial-only / closed-source tools
- ❌ Don't use affiliate links

## Categories

| Category | What belongs here |
|---|---|
| Initialization & Setup | First-run setup scripts, system init tools |
| Hardening & Security | SSH hardening, firewall, intrusion prevention, fail2ban/CrowdSec |
| Network & Proxy | Reverse proxy, SSL, tunneling, DDNS, VPN, CDN |
| Deployment | Docker orchestration, PaaS, app stores, compose collections |
| Monitoring | Uptime monitoring, server metrics, status pages |
| Backup & Recovery | Backup tools, backup strategies, restore tools |
| AI Self-Hosting | LLM runtimes, AI frontends, RAG, vector DBs |
| Audit & Compliance | Security auditing, vulnerability scanning, compliance checking |

## Reporting Issues

- **Broken link** — open an issue with `[Broken Link]` in the title, or run `./scripts/validate-links.sh`
- **Miscategorized tool** — open an issue suggesting the correct category
- **Outdated tool** — open an issue if a tool is no longer maintained; it should move to Archived / Historical

## Scripts

- `scripts/update-metadata.sh` — refresh activity markers from the GitHub API (`--check` to report, `--update` to rewrite READMEs). Requires `gh auth` or `GITHUB_TOKEN`.
- `scripts/validate-links.sh` — verify all README links are reachable (`--timeout SECONDS`). Exits 1 on broken links.
- `scripts/check-links.sh` — legacy link checker.

## Questions?

Open an issue with the `question` label. We're happy to help.
