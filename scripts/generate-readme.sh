#!/usr/bin/env bash
# generate-readme.sh — Generate README.md / README.zh.md from data/tools.yaml
#
# The YAML file data/tools.yaml is the single source of truth for the tool
# lists. This script renders the awesome-list READMEs from it.
#
# Usage:
#   ./scripts/generate-readme.sh                # generate both en + zh (alias for --lang all)
#   ./scripts/generate-readme.sh --lang en      # generate README.md only
#   ./scripts/generate-readme.sh --lang zh      # generate README.zh.md only
#   ./scripts/generate-readme.sh --lang all     # generate both
#   ./scripts/generate-readme.sh --check        # verify READMEs match YAML; exit 1 if drift
#   ./scripts/generate-readme.sh --check --lang en
#
# Requirements: python3 with PyYAML (python3 -c "import yaml").
# Exit codes: 0 = success / no drift, 1 = drift detected (--check), 2 = usage/env error.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DATA_FILE="$REPO_DIR/data/tools.yaml"

LANG_TARGET="all"
CHECK_ONLY=0

usage() {
    cat <<EOF
Usage: $0 [--lang en|zh|all] [--check]
  Generate README.md / README.zh.md from data/tools.yaml.
  --check   Verify the READMEs are in sync with the YAML data source; exit 1 on drift.
  --lang    en | zh | all (default: all)
EOF
    exit 2
}

while [ $# -gt 0 ]; do
    case "$1" in
        --lang) LANG_TARGET="$2"; shift 2 ;;
        --check) CHECK_ONLY=1; shift ;;
        -h|--help) usage ;;
        *) echo "Unknown argument: $1" >&2; usage ;;
    esac
done

case "$LANG_TARGET" in
    en|zh|all) ;;
    *) echo "Invalid --lang value: $LANG_TARGET (expected en|zh|all)" >&2; usage ;;
esac

if [ ! -f "$DATA_FILE" ]; then
    echo "ERROR: data source not found: $DATA_FILE" >&2
    exit 2
fi

if ! python3 -c 'import yaml' 2>/dev/null; then
    echo "ERROR: PyYAML is required (pip install pyyaml)." >&2
    exit 2
fi

# Hand off to the embedded Python renderer. We pass the repo dir, data file,
# language target and check flag via arguments so the Python stays self-contained.
python3 - "$REPO_DIR" "$DATA_FILE" "$LANG_TARGET" "$CHECK_ONLY" <<'PYEOF'
import os
import sys
import yaml

repo_dir, data_file, lang_target, check_only = sys.argv[1:5]
check_only = int(check_only)

with open(data_file, encoding="utf-8") as f:
    data = yaml.safe_load(f)

categories = data["categories"]
tools = data["tools"]

# activity_status -> emoji marker
MARKERS = {
    "active": "🟢",
    "maintained": "🟡",
    "stagnant": "🔴",
    "archived": "⚫",
}

# Index tools by category, preserving YAML order.
by_cat = {c["id"]: [] for c in categories}
for t in tools:
    by_cat[t["category"]].append(t)


def loc(value, lang):
    """Localize a field that may be a plain string or an {en, zh} dict."""
    if isinstance(value, dict):
        return value.get(lang, value.get("en", ""))
    return value


def render_tool_line(t, lang):
    marker = MARKERS.get(t.get("activity_status", "active"), "🟢")
    name = loc(t["name"], lang)
    url = t["url"]
    desc = loc(t["description"], lang)
    extras = ""
    for e in t.get("extra_links", []) or []:
        extras += f" + [{loc(e['name'], lang)}]({e['url']})"
    lang_tag = f" `{t['language']}`" if t.get("language") else ""
    return f"- {marker} [{name}]({url}){extras} - {desc}{lang_tag}"


# ---------------------------------------------------------------------------
# Static templates (header, TOC, activity markers, getting-started path,
# contributing, license). Only the tool-list sections are generated from YAML.
# ---------------------------------------------------------------------------

HEADER = {
"en": """# Awesome VPS — Curated Tools for Server Setup, Security & Self-Hosting

A curated list of tools and resources for VPS users—from initial setup and security hardening to deployment, monitoring, and backup. Whether you're running a cloud server for the first time or managing a homelab with Docker, you'll find the right tools here. Organized by the real workflow of a server administrator: secure first, deploy second, monitor always.

> **New to VPS?** Skip to the [🚀 Getting Started Path](#-getting-started-path) — a step-by-step guide from zero to production-ready.

## Table of Contents

- [🚀 Getting Started Path](#-getting-started-path)
- [📊 Quick Navigation](#-quick-navigation)
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
""",
"zh": """# Awesome VPS — 服务器建站、安全加固与自托管工具合集

面向 VPS 用户的精选工具与资源列表——从系统初始化、安全加固到应用部署、监控和备份。无论你是第一次使用云服务器，还是用 Docker 搭建 Homelab，都能在这里找到合适的工具。按服务器运维的真实流程组织：先安全，再部署，持续监控。

> **刚接触 VPS？** 直接看 [🚀 新手引导路径](#-新手引导路径)——从零到生产就绪的完整步骤。

## 目录

- [🚀 新手引导路径](#-新手引导路径)
- [📊 快速导航](#-快速导航)
- [🔧 初始化与设置](#-初始化与设置)
- [🛡️ 加固与安全](#-加固与安全)
- [🌐 网络与反代](#-网络与反代)
- [📦 部署](#-部署)
- [📊 监控](#-监控)
- [💾 备份与恢复](#-备份与恢复)
- [🤖 AI 自托管](#-ai-自托管)
- [🔍 审计与合规](#-审计与合规)
- [🗃️ 归档 / 历史](#-归档--历史)
- [🧩 0x10debug 生态](#-0x10debug-生态)
- [贡献指南](#贡献指南)
- [许可证](#许可证)

## 活跃度标记

每个工具都带有活跃度标记，反映其源码仓库的健康状态：

- 🟢 **活跃** — 最近 6 个月内有 commit
- 🟡 **维护** — 最近 6–12 个月内有 commit
- 🔴 **停滞** — 12 个月以上无 commit
- ⚫ **归档** — 仓库已归档/只读

标记由 `scripts/update-metadata.sh` 通过 GitHub API 刷新。运行 `./scripts/update-metadata.sh --check` 查看最新报告。

---

## 🚀 新手引导路径

刚接触 VPS？以下是从裸机到生产就绪的完整路径：

### 第 1 步：安全加固服务器（10 分钟）

在安装任何东西之前，先锁定你的服务器。更新系统、创建非 root 用户并配置 SSH 密钥、禁用 root 登录、开启防火墙。

→ 使用 [vps-bootstrap](https://github.com/0x10debug/vps-bootstrap) 一条命令完成，或手动操作：
`apt update && apt upgrade` → 创建用户 → 添加 SSH 密钥 → 编辑 `sshd_config` → 启用 UFW。

### 第 2 步：安装 Docker（5 分钟）

容器化是 VPS 部署服务的标准方式。Docker 让应用隔离运行、易于更新。

→ [vps-bootstrap](https://github.com/0x10debug/vps-bootstrap) 包含 Docker 安装，或手动安装 [Docker Engine](https://docs.docker.com/engine/install/) + [Docker Compose](https://docs.docker.com/compose/)。

### 第 3 步：配置反向代理（15 分钟）

反向代理将流量路由到你的服务，并自动管理 SSL 证书。这是通过 HTTPS 安全暴露应用的方式。

→ 使用 [network-toolkit](https://github.com/0x10debug/network-toolkit) 获取预配置模板，或选择 [Caddy](https://caddyserver.com/)、[Traefik](https://traefik.io/)、[Nginx Proxy Manager](https://nginxproxymanager.com/)。

### 第 4 步：部署你的第一个应用（10 分钟）

选择一个 Docker Compose 食谱并运行。从简单的开始——也许是一个媒体服务器或密码管理器。

→ 浏览 [compose-recipes](https://github.com/0x10debug/compose-recipes) 获取场景化套件，或在 [linuxserver.io](https://docs.linuxserver.io/) 找单个应用的 compose 文件。

### 第 5 步：设置监控（5 分钟）

知道你的服务什么时候挂了。一个简单的可用性监控几分钟就能搭好，让你不用从用户投诉中发现宕机。

→ 部署 [monitor-stack](https://github.com/0x10debug/monitor-stack) 或安装 [Uptime Kuma](https://github.com/louislam/uptime-kuma) + [Beszel](https://github.com/henrygd/beszel)。

### 第 6 步：配置备份（10 分钟）

从没测试过的备份只是美好的愿望。设置加密的自动备份，并执行一次恢复演练。

→ 使用 [backup-kit](https://github.com/0x10debug/backup-kit) 获取预配置策略，或手动配置 [Restic](https://restic.net/) / [Kopia](https://kopia.io/)。

### 第 7 步：运行安全审计（15 分钟）

检查你的配置是否有弱点。SSH 设置是否合规？容器镜像是否有漏洞？配置是否偏离了基线？

→ 运行 [security-audit](https://github.com/0x10debug/security-audit) 或使用 [Lynis](https://cisofy.com/lynis/)。

🎉 **你的 VPS 现在生产就绪了。**

---
""",
}

FOOTER = {
"en": """## Contributing

Contributions are welcome! To add a tool:

1. Fork this repository
2. Add the tool to `data/tools.yaml` (the single source of truth)
3. Run `./scripts/generate-readme.sh --lang all` to regenerate `README.md` and `README.zh.md`
4. Run `./scripts/validate-links.sh` to confirm links are reachable
5. Submit a pull request

### Entry Format (YAML)

```yaml
- name: Tool Name
  url: https://github.com/user/repo
  category: deployment        # one of the category ids in data/tools.yaml
  language: Go                # primary implementation language
  activity_status: active     # active | maintained | stagnant | archived
  description:
    en: "One-line description of what it does."
    zh: "一句话描述它的功能。"
```

The `activity_status` field maps to an **activity marker**, refreshed automatically by `scripts/update-metadata.sh`. Use `active` (🟢) for new entries; the script will correct it on the next run if the repo is less active.

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
- Provide both `en` and `zh` descriptions
- Each category should contain 3–15 tools; split or merge categories if needed

### Scripts

- `scripts/generate-readme.sh` — render README.md / README.zh.md from `data/tools.yaml` (`--lang en|zh|all`, `--check` to verify no drift)
- `scripts/update-metadata.sh` — refresh activity markers from the GitHub API (`--check` to report, `--update` to rewrite YAML + READMEs)
- `scripts/validate-links.sh` — verify all README links are reachable (`--timeout SECONDS`)
- `scripts/check-links.sh` — legacy link checker

---

## License

[MIT](./LICENSE)
""",
"zh": """## 贡献指南

欢迎贡献！添加工具的步骤：

1. Fork 本仓库
2. 在 `data/tools.yaml`（单一数据源）中添加工具
3. 运行 `./scripts/generate-readme.sh --lang all` 重新生成 `README.md` 和 `README.zh.md`
4. 运行 `./scripts/validate-links.sh` 确认链接可达
5. 提交 Pull Request

### 条目格式（YAML）

```yaml
- name: 工具名
  url: https://github.com/user/repo
  category: deployment        # data/tools.yaml 中定义的分类 id
  language: Go                # 主要实现语言
  activity_status: active     # active | maintained | stagnant | archived
  description:
    en: "One-line description of what it does."
    zh: "一句话描述它的功能。"
```

`activity_status` 字段对应**活跃度标记**，由 `scripts/update-metadata.sh` 自动刷新。新条目先用 `active`（🟢），下次脚本运行时会按仓库实际活跃度修正。

### 活跃度标记

- 🟢 **活跃** — 最近 6 个月内有 commit
- 🟡 **维护** — 最近 6–12 个月内有 commit
- 🔴 **停滞** — 12 个月以上无 commit
- ⚫ **归档** — 仓库已归档/只读

变为 🔴 或 ⚫ 的工具会移到[归档 / 历史](#-归档--历史)小节。

### 准则

- 工具必须开源（或有免费的自托管版本）
- 描述必须原创（不要复制工具的 README）
- 放在正确的分类下
- 同时提供 `en` 和 `zh` 描述
- 每个分类应有 3–15 个工具；必要时拆分或合并分类

### 脚本

- `scripts/generate-readme.sh` — 从 `data/tools.yaml` 生成 README.md / README.zh.md（`--lang en|zh|all`，`--check` 校验是否一致）
- `scripts/update-metadata.sh` — 通过 GitHub API 刷新活跃度标记（`--check` 仅报告，`--update` 改写 YAML + README）
- `scripts/validate-links.sh` — 校验 README 中所有链接可达（`--timeout 秒数`）
- `scripts/check-links.sh` — 旧版链接检查器

---

## 许可证

[MIT](./LICENSE)
""",
}


def render_category(cat, lang):
    emoji = cat["emoji"]
    title = loc(cat["title"], lang)
    intro = loc(cat["intro"], lang)
    lines = []
    lines.append(f"## {emoji} {title}")
    lines.append("")
    lines.append(intro)
    lines.append("")
    for t in by_cat[cat["id"]]:
        lines.append(render_tool_line(t, lang))
    lines.append("")
    if cat.get("note"):
        lines.append(f"> {loc(cat['note'], lang)}")
        lines.append("")
    if cat.get("outro"):
        lines.append(loc(cat["outro"], lang))
        lines.append("")
    lines.append("---")
    lines.append("")
    return "\n".join(lines)


# Anchor slug for a category title (GitHub-style: lowercase, spaces→hyphens,
# emoji stripped, punctuation removed).
def anchor_slug(emoji, title):
    import re
    s = f"{emoji} {title}"
    s = re.sub(r'[^\w\s-]', '', s, flags=re.UNICODE)
    s = s.strip().lower().replace(' ', '-')
    s = re.sub(r'-+', '-', s)
    return s


# Short "what it covers" description for the quick-nav table, per category id.
# These are concise summaries distinct from the full intro text.
CATEGORY_SUMMARIES = {
    "init": {
        "en": "First minutes after getting a fresh server",
        "zh": "拿到新服务器后的最初几分钟",
    },
    "hardening": {
        "en": "SSH, firewall, fail2ban, baseline hardening",
        "zh": "SSH、防火墙、fail2ban、基线加固",
    },
    "network": {
        "en": "Reverse proxy, SSL, tunneling, DNS",
        "zh": "反向代理、SSL、隧道、DNS",
    },
    "deployment": {
        "en": "Docker Compose recipes and app suites",
        "zh": "Docker Compose 食谱和应用套件",
    },
    "monitoring": {
        "en": "Uptime, metrics, logs, alerting",
        "zh": "可用性、指标、日志、告警",
    },
    "backup": {
        "en": "Encrypted backup, restore drills, 3-2-1",
        "zh": "加密备份、恢复演练、3-2-1 策略",
    },
    "ai": {
        "en": "Ollama, Open WebUI, RAG, LiteLLM",
        "zh": "Ollama、Open WebUI、RAG、LiteLLM",
    },
    "audit": {
        "en": "CIS benchmark, Lynis, drift detection",
        "zh": "CIS 基线、Lynis、漂移检测",
    },
    "archived": {
        "en": "Historical tools no longer actively maintained",
        "zh": "已不再活跃维护的历史工具",
    },
    "ecosystem": {
        "en": "Our integrated tool suite",
        "zh": "我们的集成工具套件",
    },
}


def render_quick_nav(lang):
    """Generate a compact navigation table with per-category tool counts."""
    lines = []
    if lang == "en":
        lines.append("## 📊 Quick Navigation")
        lines.append("")
        lines.append("| Category | Tools | What it covers |")
        lines.append("|---|---|---|")
    else:
        lines.append("## 📊 快速导航")
        lines.append("")
        lines.append("| 分类 | 工具数 | 覆盖范围 |")
        lines.append("|---|---|---|")

    total = 0
    active_cats = 0
    archived_cats = 0
    for cat in categories:
        count = len(by_cat[cat["id"]])
        total += count
        if cat["id"] == "archived":
            archived_cats += 1
        else:
            active_cats += 1
        emoji = cat["emoji"]
        title = loc(cat["title"], lang)
        slug = anchor_slug(emoji, title)
        summary = CATEGORY_SUMMARIES.get(cat["id"], {}).get(lang, loc(cat["intro"], lang))
        lines.append(f"| [{emoji} {title}](#{slug}) | {count} | {summary} |")

    lines.append("")
    if lang == "en":
        lines.append(f"**Total: {total} tools** across {active_cats} active categories"
                     + (f" (+{archived_cats} archived)." if archived_cats else "."))
    else:
        lines.append(f"**共 {total} 个工具**，分布在 {active_cats} 个活跃分类中"
                     + (f"（+{archived_cats} 个归档）。" if archived_cats else "。"))
    lines.append("")
    # Activity breakdown sub-section
    lines.append(render_stats(lang))
    lines.append("---")
    lines.append("")
    return "\n".join(lines)


def render_stats(lang):
    """Generate a statistics summary showing activity breakdown."""
    status_counts = {"active": 0, "maintained": 0, "stagnant": 0, "archived": 0}
    for t in tools:
        status = t.get("activity_status", "active")
        status_counts[status] = status_counts.get(status, 0) + 1

    lines = []
    if lang == "en":
        lines.append("### Activity Breakdown")
        lines.append("")
        lines.append(f"- 🟢 **Active**: {status_counts.get('active', 0)}")
        lines.append(f"- 🟡 **Maintained**: {status_counts.get('maintained', 0)}")
        lines.append(f"- 🔴 **Stagnant**: {status_counts.get('stagnant', 0)}")
        lines.append(f"- ⚫ **Archived**: {status_counts.get('archived', 0)}")
    else:
        lines.append("### 活跃度分布")
        lines.append("")
        lines.append(f"- 🟢 **活跃**: {status_counts.get('active', 0)}")
        lines.append(f"- 🟡 **维护**: {status_counts.get('maintained', 0)}")
        lines.append(f"- 🔴 **停滞**: {status_counts.get('stagnant', 0)}")
        lines.append(f"- ⚫ **归档**: {status_counts.get('archived', 0)}")
    lines.append("")
    return "\n".join(lines)


def render_readme(lang):
    # The HEADER template ends with "---\n" after the Activity Markers section,
    # followed by the Getting Started Path. We split the header at the
    # "## 🚀 Getting Started Path" / "## 🚀 新手引导路径" marker to insert
    # the dynamic Quick Navigation + Stats sections in between.
    header = HEADER[lang]
    gs_marker_en = "## 🚀 Getting Started Path"
    gs_marker_zh = "## 🚀 新手引导路径"
    gs_marker = gs_marker_en if lang == "en" else gs_marker_zh

    idx = header.find(gs_marker)
    if idx > 0:
        header_top = header[:idx]
        header_bottom = header[idx:]
    else:
        header_top = header
        header_bottom = ""

    parts = [header_top.rstrip() + "\n\n"]
    parts.append(render_quick_nav(lang))
    if header_bottom:
        parts.append(header_bottom.rstrip() + "\n")
    for cat in categories:
        parts.append(render_category(cat, lang))
    parts.append(FOOTER[lang])
    return "\n".join(parts)


def file_for(lang):
    return os.path.join(repo_dir, "README.md" if lang == "en" else "README.zh.md")


langs = ["en", "zh"] if lang_target == "all" else [lang_target]

drift = False
for lang in langs:
    content = render_readme(lang)
    path = file_for(lang)
    if check_only:
        if not os.path.exists(path):
            print(f"DRIFT: {os.path.basename(path)} does not exist")
            drift = True
            continue
        with open(path, encoding="utf-8") as f:
            existing = f.read()
        if existing == content:
            print(f"OK: {os.path.basename(path)} is in sync with data/tools.yaml")
        else:
            print(f"DRIFT: {os.path.basename(path)} differs from data/tools.yaml")
            drift = True
    else:
        with open(path, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"Generated {os.path.basename(path)} from data/tools.yaml")

if check_only and drift:
    print("")
    print("READMEs are out of sync. Run: ./scripts/generate-readme.sh --lang all")
    sys.exit(1)
PYEOF
