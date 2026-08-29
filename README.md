# Awesome VPS — Curated Tools for Server Setup, Security & Self-Hosting

A curated list of tools and resources for VPS users—from initial setup and security hardening to deployment, monitoring, and backup. Whether you're running a cloud server for the first time or managing a homelab with Docker, you'll find the right tools here. Organized by the real workflow of a server administrator: secure first, deploy second, monitor always.

> **New to VPS?** Skip to the [🚀 Getting Started Path](#-getting-started-path) — a step-by-step guide from zero to production-ready.

## Table of Contents

- [🚀 Getting Started Path](#-getting-started-path)
- [🔧 Initialization & Setup](#-initialization--setup)
- [🛡️ Hardening & Security](#-hardening--security)
- [🌐 Network & Proxy](#-network--proxy)
- [📦 Deployment](#-deployment)
- [📊 Monitoring](#-monitoring)
- [💾 Backup & Recovery](#-backup--recovery)
- [🤖 AI Self-Hosting](#-ai-self-hosting)
- [🔍 Audit & Compliance](#-audit--compliance)
- [🗃️ Archived / Historical](#-archived--historical)
- [🧩 0x10debug Ecosystem](#-0x10debug-ecosystem)
- [Contributing](#contributing)
- [License](#license)

## Activity Markers

Each tool is tagged with an activity marker reflecting the health of its source repository:

- 🟢 **Active** — commit within the last 6 months
- 🟡 **Maintained** — commit within the last 6–12 months
- 🔴 **Stagnant** — no commit in 12+ months
- ⚫ **Archived** — repository is archived/read-only

Markers are refreshed by `scripts/update-metadata.sh` (GitHub API). Run `./scripts/update-metadata.sh --check` to inspect the latest report.

---

## 🚀 Getting Started Path

New to VPS? Here's the path from a fresh server to production-ready:

### Step 1: Secure Your Server (10 min)

Before installing anything, lock down your server. Update the system, create a non-root user with SSH keys, disable root login, and enable a firewall.

→ Use [vps-bootstrap](https://github.com/0x10debug/vps-bootstrap) for a one-command setup, or do it manually:
`apt update && apt upgrade` → create user → add SSH key → edit `sshd_config` → enable UFW.

### Step 2: Install Docker (5 min)

Containerization is the standard way to deploy services on a VPS. Docker keeps your apps isolated and easy to update.

→ [vps-bootstrap](https://github.com/0x10debug/vps-bootstrap) includes Docker installation, or install [Docker Engine](https://docs.docker.com/engine/install/) + [Docker Compose](https://docs.docker.com/compose/) manually.

### Step 3: Set Up Reverse Proxy (15 min)

A reverse proxy routes traffic to your services and manages SSL certificates automatically. This is how you expose apps securely with HTTPS.

→ Use [network-toolkit](https://github.com/0x10debug/network-toolkit) for pre-configured templates, or pick [Caddy](https://caddyserver.com/), [Traefik](https://traefik.io/), or [Nginx Proxy Manager](https://nginxproxymanager.com/).

### Step 4: Deploy Your First App (10 min)

Choose a Docker Compose recipe and run it. Start simple—maybe a media server or a password manager.

→ Browse [compose-recipes](https://github.com/0x10debug/compose-recipes) for scenario-based suites, or find individual app compose files on [linuxserver.io](https://docs.linuxserver.io/).

### Step 5: Set Up Monitoring (5 min)

Know when your services go down. A simple uptime monitor takes minutes to set up and saves you from discovering outages from user complaints.

→ Deploy [monitor-stack](https://github.com/0x10debug/monitor-stack) or install [Uptime Kuma](https://github.com/louislam/uptime-kuma) + [Beszel](https://github.com/henrygd/beszel).

### Step 6: Configure Backups (10 min)

A backup you've never tested is just a hope. Set up encrypted, automated backups and run a restore drill.

→ Use [backup-kit](https://github.com/0x10debug/backup-kit) for pre-configured strategies, or set up [Restic](https://restic.net/) / [Kopia](https://kopia.io/) manually.

### Step 7: Run a Security Audit (15 min)

Check your configuration for weaknesses. Are your SSH settings compliant? Are your container images vulnerable? Has any config drifted from baseline?

→ Run [security-audit](https://github.com/0x10debug/security-audit) or use [Lynis](https://cisofy.com/lynis/).

🎉 **Your VPS is now production-ready.**

---

## 🔧 Initialization & Setup

Tools for the first few minutes after you get a fresh server.

- 🟢 [vps-bootstrap](https://github.com/0x10debug/vps-bootstrap) - One-command VPS initialization and security hardening with CrowdSec, Docker, and MOTD dashboard. `Shell`
- 🟢 [vpskit](https://github.com/mariusdjen/vpskit) - 9-step interactive VPS setup: updates, user creation, SSH hardening, firewall, Docker, Caddy. `Shell`
- 🟢 [bento](https://github.com/felipefontoura/bento) - Turns a fresh VPS into a hardened Docker Swarm with Traefik, Portainer, and TLS in 15 minutes. `Shell`
- 🟡 [vpsarmor](https://github.com/flegoff/vpsarmor) - Security boilerplate for Ubuntu LTS and Debian servers. KISS philosophy, 5 layers of protection. `Shell`
- 🟢 [linvpsliteinit](https://github.com/tonysbb/linvpsliteinit) - Lightweight VPS setup toolkit for Debian, Ubuntu, and Alpine. Init once, add components later. `Shell`

---

## 🛡️ Hardening & Security

Tools to protect your server from attacks.

- 🟢 [CrowdSec](https://github.com/crowdsecurity/crowdsec) - Modern intrusion prevention with crowdsourced threat intelligence. Replaces fail2ban with community blocklists and multi-layer bouncers. `Go`
- 🟢 [fail2ban](https://github.com/fail2ban/fail2ban) - Classic brute-force protection. Blocks IPs after repeated failed login attempts. `Python`
- 🟢 [security-audit](https://github.com/0x10debug/security-audit) - VPS security auditor with CIS Benchmark checks, drift detection, and one-click fixes. `Shell`
- 🟢 [Lynis](https://cisofy.com/lynis/) - Security auditing tool for Unix-based systems. Reports hardening suggestions. `Shell`
- 🟢 [OSSEC](https://www.ossec.net/) - Host-based intrusion detection system. Monitors logs, detects rootkits, alerts on anomalies. `C`
- 🟢 [ssh-audit](https://github.com/jtesta/ssh-audit) - SSH server and client configuration auditor. Checks host keys, algorithms, and policy compliance. `Python`
- 🟡 [CIS-CAT](https://learn.cisecurity.org/cis-cat-pro-quiz) - CIS Benchmark configuration assessment tool. Professional compliance scanning. `Java`

---

## 🌐 Network & Proxy

Tools for exposing services, managing SSL, and traversing NAT.

- 🟢 [network-toolkit](https://github.com/0x10debug/network-toolkit) - Reverse proxy, SSL, tunnel, and DDNS combined into deployable templates for VPS. `Shell`
- 🟢 [Caddy](https://github.com/caddyserver/caddy) - Web server with automatic HTTPS. Simplest reverse proxy for self-hosted apps. `Go`
- 🟢 [Traefik](https://github.com/traefik/traefik) - Cloud-native reverse proxy with Docker label routing and automatic service discovery. `Go`
- 🟢 [Nginx Proxy Manager](https://github.com/NginxProxyManager/nginx-proxy-manager) - Nginx reverse proxy with web GUI, free SSL via Let's Encrypt. `JavaScript`
- 🟢 [SWAG](https://github.com/linuxserver/docker-swag) - Nginx + auto SSL + pre-built reverse proxy configs by linuxserver.io. `Shell`
- 🟢 [acme.sh](https://github.com/acmesh-official/acme.sh) - Pure shell ACME client. Supports multiple CAs and DNS API providers. `Shell`
- 🟢 [frp](https://github.com/fatedier/frp) - Fast reverse proxy for NAT traversal. Expose local services through a public server. `Go`
- 🟢 [rathole](https://github.com/rathole-org/rathole) - Lightweight, high-performance alternative to frp, written in Rust. `Rust`
- 🟢 [Tailscale](https://github.com/tailscale/tailscale) - WireGuard-based mesh VPN with zero config. Connect your devices securely. `Go`
- 🟢 [Headscale](https://github.com/juanfont/headscale) - Self-hosted, open-source control server for Tailscale. Run your own mesh VPN. `Go`
- 🟢 [NetBird](https://github.com/netbirdio/netbird) - Self-hosted WireGuard mesh VPN with SSO, MFA, and web UI. `Go`
- 🟢 [WireGuard](https://www.wireguard.com/) - Fast, modern VPN protocol. Use [wireguard-install](https://github.com/angristan/wireguard-install) for one-click setup. `C`
- 🟢 [ddns-go](https://github.com/jeessy2/ddns-go) - Automatic DDNS client with web UI. Supports Cloudflare, Aliyun, Tencent, and more. `Go`
- 🟢 [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/) - Expose services without opening inbound ports. Outbound-only tunnel to Cloudflare edge. `Go`

---

## 📦 Deployment

Tools for deploying and managing applications on your VPS.

- 🟢 [Docker](https://github.com/moby/moby) - Container platform. The foundation of modern VPS deployment. `Go`
- 🟢 [Docker Compose](https://github.com/docker/compose) - Define and run multi-container applications. Essential for self-hosting. `Go`
- 🟢 [compose-recipes](https://github.com/0x10debug/compose-recipes) - Scenario-based Docker Compose suites for self-hosted apps. Home media, productivity, dev environment, and more. `YAML`
- 🟢 [Coolify](https://github.com/coollabsio/coolify) - Open-source self-hostable PaaS. Deploy apps and databases with 280+ one-click services. `TypeScript`
- 🟢 [Dokploy](https://github.com/Dokploy/dokploy) - Lightweight PaaS with native Docker Compose support. Minimal footprint for small VPS. `TypeScript`
- 🟢 [CapRover](https://github.com/caprover/caprover) - Self-hosted PaaS with Docker Swarm and large one-click app library. `TypeScript`
- 🟢 [1Panel](https://github.com/1Panel-dev/1Panel) - Modern Linux server management panel with app store and AI management. `Go`
- 🟢 [Portainer](https://github.com/portainer/portainer) - Docker management web UI. Visual container management for all levels. `TypeScript`
- 🟢 [Umbrel](https://github.com/getumbrel/umbrel) - Home server OS with 300+ app store. Beautiful UI, designed for home servers. `TypeScript`
- 🟢 [Runtipi](https://github.com/runtipi/runtipi) - Personal homeserver with one-command setup and one-click app installs. `TypeScript`

---

## 📊 Monitoring

Tools to know if your services are up and your server is healthy.

- 🟢 [monitor-stack](https://github.com/0x10debug/monitor-stack) - Lightweight monitoring stack: uptime, server metrics, Docker stats, and security alerts in one deploy. `Shell`
- 🟢 [Uptime Kuma](https://github.com/louislam/uptime-kuma) - Fancy self-hosted uptime monitor with 90+ notification channels and status pages. `JavaScript`
- 🟢 [Beszel](https://github.com/henrygd/beszel) - Lightweight server monitoring with historical data, Docker stats, and alerts. `Go`
- 🟢 [Netdata](https://github.com/netdata/netdata) - Real-time infrastructure monitoring with per-second metrics and ML anomaly detection. `C`
- 🟢 [Grafana](https://github.com/grafana/grafana) + [Prometheus](https://github.com/prometheus/prometheus) - Professional metrics and dashboards. Powerful but resource-heavy. `Go`
- 🟢 [Nezha](https://github.com/nezhahq/nezha) - Multi-server monitoring panel popular in the Chinese VPS community. `Go`

---

## 💾 Backup & Recovery

Tools to ensure your data survives disasters.

- 🟢 [backup-kit](https://github.com/0x10debug/backup-kit) - Pre-configured backup strategies for VPS: encrypted, automated, with restore drills and Docker volume support. `Shell`
- 🟢 [Restic](https://github.com/restic/restic) - Fast, secure, encrypted backup tool with deduplication. CLI standard for server backups. `Go`
- 🟢 [Kopia](https://github.com/kopia/kopia) - Encrypted snapshot backup with web UI and multi-backend support. `Go`
- 🟢 [BorgBackup](https://github.com/borgbackup/borg) - Deduplicating, compressing, authenticated backup. The engine behind many server backup workflows. `Python`
- 🟢 [Borgmatic](https://github.com/borgmatic-collective/borgmatic) - YAML-configured wrapper around BorgBackup. Declarative backup with cron integration. `Python`
- 🟢 [Duplicati](https://github.com/duplicati/duplicati) - Backup tool with web UI and multi-backend support. `C#`
- 🟢 [rclone](https://github.com/rclone/rclone) - Cloud storage Swiss Army knife. Sync, mount, and copy across 70+ backends. `Go`

---

## 🤖 AI Self-Hosting

Tools to run AI models on your own server.

- 🟢 [ai-workstation](https://github.com/0x10debug/ai-workstation) - One-command AI deployment on VPS: Ollama + Open WebUI with reverse proxy, auth, and model management. `Shell`
- 🟢 [Ollama](https://github.com/ollama/ollama) - Run Llama, Mistral, Phi, Qwen, and other models locally. The standard for self-hosted LLMs. `Go`
- 🟢 [Open WebUI](https://github.com/open-webui/open-webui) - ChatGPT-style frontend for Ollama and OpenAI-compatible APIs. Feature-rich, offline-capable. `Python`
- 🟢 [Lobe Chat](https://github.com/lobehub/lobehub) - Beautiful multi-model AI chat with plugin ecosystem. `TypeScript`
- 🟢 [AnythingLLM](https://github.com/Mintplex-Labs/anything-llm) - Document Q&A with vector storage and RAG. `JavaScript`
- 🟢 [vLLM](https://github.com/vllm-project/vllm) - High-throughput LLM inference engine. For GPU servers with serious compute needs. `Python`

---

## 🔍 Audit & Compliance

Tools to check your server for vulnerabilities and compliance.

- 🟢 [security-audit](https://github.com/0x10debug/security-audit) - CIS Benchmark compliance, drift detection, container scanning, and auto-fix—designed for VPS. `Shell`
- 🟢 [Lynis](https://cisofy.com/lynis/) - Security auditing for Linux/Unix. Detailed hardening suggestions. `Shell`
- 🟢 [Trivy](https://github.com/aquasecurity/trivy) - Container image and filesystem vulnerability scanner. `Go`
- 🟡 [chkrootkit](http://www.chkrootkit.org/) - Rootkit detector. Checks for known rootkit signatures. `C`
- 🟢 [CrowdSec Dashboard](https://app.crowdsec.net/) - Visualize attacks blocked by CrowdSec. Threat intelligence at a glance. `Web`

---

## 🗃️ Archived / Historical

Tools that were once useful but whose upstream repositories are now archived. Kept here for reference; prefer the active alternatives above.

- ⚫ [Homarr](https://github.com/ajnart/homarr) - Customizable dashboard for interacting with Docker containers on a homeserver. Archived upstream; consider [Homepage](https://github.com/gethomepage/homepage) or [Dashy](https://github.com/Lissy93/dashy) instead. `TypeScript`

> Know an archived VPS tool that should be listed here? Open an issue or PR.

---

## 🧩 0x10debug Ecosystem

The repos below, maintained under the [0x10debug](https://github.com/0x10debug) account, form a complete VPS operations + security toolchain. Each one is designed to be composable: bootstrap a server, harden it, deploy apps, monitor, back up, and audit—end to end.

- 🟢 [vps-security-enhancement-scripts](https://github.com/0x10debug/vps-security-enhancement-scripts) - VPS security hardening script collection (SSH, firewall, kernel, fail2ban/CrowdSec baselines).
- 🟢 [vps-bootstrap](https://github.com/0x10debug/vps-bootstrap) - VPS initialization CLI: one command from fresh server to hardened, Docker-ready host.
- 🟢 [compose-recipes](https://github.com/0x10debug/compose-recipes) - Docker Compose deployment suites organized by self-hosting scenario.
- 🟢 [network-toolkit](https://github.com/0x10debug/network-toolkit) - Network configuration template library: reverse proxy, SSL, tunnels, DDNS.
- 🟢 [monitor-stack](https://github.com/0x10debug/monitor-stack) - Monitoring stack: uptime, server metrics, Docker stats, and security alerts.
- 🟢 [backup-kit](https://github.com/0x10debug/backup-kit) - Backup tooling with pre-configured encrypted strategies and restore drills.
- 🟢 [security-audit](https://github.com/0x10debug/security-audit) - Deep security audit: CIS Benchmark checks, drift detection, container scanning, auto-fix.
- 🟢 [ai-workstation](https://github.com/0x10debug/ai-workstation) - AI workstation one-click deploy: Ollama + Open WebUI with reverse proxy and auth.

Together they cover the full VPS lifecycle: **bootstrap → harden → deploy → monitor → back up → audit**.

---

## Contributing

Contributions are welcome! To add a tool:

1. Fork this repository
2. Add the tool to the appropriate category in both `README.md` and `README.zh.md`
3. Follow the entry format (see below)
4. Run `./scripts/validate-links.sh` to confirm links are reachable
5. Submit a pull request

### Entry Format

```markdown
- 🟢 [Tool Name](https://github.com/user/repo) - One-line description of what it does. `Language`
```

The leading emoji is an **activity marker**, refreshed automatically by `scripts/update-metadata.sh`. Use 🟢 for new entries; the script will correct it on the next run if the repo is less active.

### Activity Markers

- 🟢 **Active** — commit within the last 6 months
- 🟡 **Maintained** — commit within the last 6–12 months
- 🔴 **Stagnant** — no commit in 12+ months
- ⚫ **Archived** — repository is archived/read-only

Tools that become 🔴 or ⚫ are moved to the [Archived / Historical](#-archived--historical) section.

### Guidelines

- Tools must be open-source (or have a free self-hostable tier)
- Description must be original (don't copy the tool's README)
- Place in the correct category
- Add to both English and Chinese READMEs
- Each category should contain 3–15 tools; split or merge categories if needed

### Scripts

- `scripts/update-metadata.sh` — refresh activity markers from the GitHub API (`--check` to report, `--update` to rewrite READMEs)
- `scripts/validate-links.sh` — verify all README links are reachable (`--timeout SECONDS`)
- `scripts/check-links.sh` — legacy link checker

---

## License

[MIT](./LICENSE)
