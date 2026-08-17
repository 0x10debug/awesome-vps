# Contributing to Awesome VPS

Thanks for your interest in contributing! This is a community-curated list of VPS tools and resources.

## How to Add a Tool

1. **Fork** this repository
2. **Add the tool** to the appropriate category in **both** `README.md` (English) and `README.zh.md` (Chinese)
3. **Follow the entry format** (see below)
4. **Submit a pull request**

## Entry Format

```markdown
- **[Tool Name](https://github.com/user/repo)** - One-line description of what it does. `Language` 🟢
```

### Fields

| Field | Requirement | Example |
|---|---|---|
| **Name** | Link to the official repo or website | `[Ollama](https://github.com/ollama/ollama)` |
| **Description** | One sentence, original wording (don't copy the tool's README) | `Run Llama, Mistral, Phi locally.` |
| **Language** | Primary implementation language | `` `Go` ``, `` `Shell` ``, `` `Python` `` |
| **Difficulty** | One of 🟢 🟡 🔴 | See levels below |

### Difficulty Levels

- 🟢 **Beginner** — One command to install and use, minimal configuration needed
- 🟡 **Intermediate** — Requires configuration or understanding of concepts
- 🔴 **Advanced** — Requires deep understanding of underlying systems

## Guidelines

### Must

- ✅ Tool is **open-source** (or has a free self-hostable tier)
- ✅ Tool is **actively maintained** (commit within last 12 months)
- ✅ Description is **original** — write it in your own words
- ✅ Tool is placed in the **correct category**
- ✅ Entry added to **both** English and Chinese READMEs

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

- **Broken link** — open an issue with `[Broken Link]` in the title
- **Miscategorized tool** — open an issue suggesting the correct category
- **Outdated tool** — open an issue if a tool is no longer maintained

## Questions?

Open an issue with the `question` label. We're happy to help.
