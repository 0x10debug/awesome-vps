# Awesome VPS — 服务器建站、安全加固与自托管工具合集

面向 VPS 用户的精选工具与资源列表——从系统初始化、安全加固到应用部署、监控和备份。无论你是第一次使用云服务器，还是用 Docker 搭建 Homelab，都能在这里找到合适的工具。按服务器运维的真实流程组织：先安全，再部署，持续监控。

> **刚接触 VPS？** 直接看 [🚀 新手引导路径](#-新手引导路径)——从零到生产就绪的完整步骤。

## 目录

- [🚀 新手引导路径](#-新手引导路径)
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

## 🔧 初始化与设置

拿到新服务器后最初几分钟要用的工具。

- 🟢 [vps-bootstrap](https://github.com/0x10debug/vps-bootstrap) - 一条命令完成 VPS 初始化和安全加固，集成 CrowdSec、Docker 和 MOTD 仪表盘。 `Shell`
- 🟢 [vpskit](https://github.com/mariusdjen/vpskit) - 9 步交互式 VPS 设置：更新、用户创建、SSH 加固、防火墙、Docker、Caddy。 `Shell`
- 🟢 [bento](https://github.com/felipefontoura/bento) - 15 分钟将裸 VPS 变成带 Traefik、Portainer 和 TLS 的 Docker Swarm。 `Shell`
- 🟡 [vpsarmor](https://github.com/flegoff/vpsarmor) - Ubuntu LTS 和 Debian 服务器的安全加固模板。KISS 原则，5 层防护。 `Shell`
- 🟢 [linvpsliteinit](https://github.com/tonysbb/linvpsliteinit) - 轻量级 VPS 设置工具包，支持 Debian、Ubuntu 和 Alpine。初始化一次，后续按需添加组件。 `Shell`

---

## 🛡️ 加固与安全

保护服务器免受攻击的工具。

- 🟢 [CrowdSec](https://github.com/crowdsecurity/crowdsec) - 现代入侵防护系统，众包威胁情报。用社区封禁列表和多层 bouncer 替代 fail2ban。 `Go`
- 🟢 [fail2ban](https://github.com/fail2ban/fail2ban) - 经典的暴力破解防护。多次登录失败后自动封禁 IP。 `Python`
- 🟢 [security-audit](https://github.com/0x10debug/security-audit) - VPS 安全审计工具，CIS Benchmark 检查、配置漂移检测、一键修复。 `Shell`
- 🟢 [Lynis](https://cisofy.com/lynis/) - Unix 系统安全审计工具。输出详细的加固建议。 `Shell`
- 🟢 [OSSEC](https://www.ossec.net/) - 基于主机的入侵检测系统。监控日志、检测 rootkit、异常告警。 `C`
- 🟢 [ssh-audit](https://github.com/jtesta/ssh-audit) - SSH 服务端与客户端配置审计工具。检查主机密钥、算法和策略合规性。 `Python`
- 🟡 [CIS-CAT](https://learn.cisecurity.org/cis-cat-pro-quiz) - CIS Benchmark 配置评估工具。专业级合规扫描。 `Java`

---

## 🌐 网络与反代

暴露服务、管理 SSL、穿透内网的工具。

- 🟢 [network-toolkit](https://github.com/0x10debug/network-toolkit) - 反向代理、SSL、内网穿透、DDNS 组合成可部署模板，专为 VPS 设计。 `Shell`
- 🟢 [Caddy](https://github.com/caddyserver/caddy) - 自动 HTTPS 的 Web 服务器。最简单的自托管反代方案。 `Go`
- 🟢 [Traefik](https://github.com/traefik/traefik) - 云原生反向代理，支持 Docker label 路由和自动服务发现。 `Go`
- 🟢 [Nginx Proxy Manager](https://github.com/NginxProxyManager/nginx-proxy-manager) - 带 Web 界面的 Nginx 反代，免费 Let's Encrypt SSL。 `JavaScript`
- 🟢 [SWAG](https://github.com/linuxserver/docker-swag) - Nginx + 自动 SSL + linuxserver.io 预置反代配置。 `Shell`
- 🟢 [acme.sh](https://github.com/acmesh-official/acme.sh) - 纯 Shell 实现的 ACME 客户端。支持多家 CA 和 DNS API。 `Shell`
- 🟢 [frp](https://github.com/fatedier/frp) - 快速反向代理，用于 NAT 穿透。通过公网服务器暴露本地服务。 `Go`
- 🟢 [rathole](https://github.com/rathole-org/rathole) - 轻量高性能的 frp 替代品，Rust 编写。 `Rust`
- 🟢 [Tailscale](https://github.com/tailscale/tailscale) - 基于 WireGuard 的零配置 mesh VPN。安全连接你的设备。 `Go`
- 🟢 [Headscale](https://github.com/juanfont/headscale) - 可自托管的开源 Tailscale 控制服务器。搭建你自己的 mesh VPN。 `Go`
- 🟢 [NetBird](https://github.com/netbirdio/netbird) - 可自托管的 WireGuard mesh VPN，支持 SSO、MFA 和 Web 界面。 `Go`
- 🟢 [WireGuard](https://www.wireguard.com/) - 快速、现代的 VPN 协议。用 [wireguard-install](https://github.com/angristan/wireguard-install) 一键安装。 `C`
- 🟢 [ddns-go](https://github.com/jeessy2/ddns-go) - 自动 DDNS 客户端，带 Web 界面。支持 Cloudflare、阿里云、腾讯云等。 `Go`
- 🟢 [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/) - 无需开放入站端口即可暴露服务。仅出站隧道连接 Cloudflare 边缘。 `Go`

---

## 📦 部署

在 VPS 上部署和管理应用的工具。

- 🟢 [Docker](https://github.com/moby/moby) - 容器平台。现代 VPS 部署的基石。 `Go`
- 🟢 [Docker Compose](https://github.com/docker/compose) - 定义和运行多容器应用。自托管必备。 `Go`
- 🟢 [compose-recipes](https://github.com/0x10debug/compose-recipes) - 场景化 Docker Compose 套件。家庭媒体、个人生产力、开发环境等。 `YAML`
- 🟢 [Coolify](https://github.com/coollabsio/coolify) - 开源可自托管 PaaS。280+ 一键部署服务和数据库。 `TypeScript`
- 🟢 [Dokploy](https://github.com/Dokploy/dokploy) - 轻量 PaaS，原生支持 Docker Compose。适合小型 VPS。 `TypeScript`
- 🟢 [CapRover](https://github.com/caprover/caprover) - 基于 Docker Swarm 的自托管 PaaS，大量一键应用。 `TypeScript`
- 🟢 [1Panel](https://github.com/1Panel-dev/1Panel) - 现代 Linux 服务器管理面板，带应用商店和 AI 管理。 `Go`
- 🟢 [Portainer](https://github.com/portainer/portainer) - Docker 管理 Web 界面。可视化容器管理。 `TypeScript`
- 🟢 [Umbrel](https://github.com/getumbrel/umbrel) - 家庭服务器 OS，300+ 应用商店。界面精美，专为家庭服务器设计。 `TypeScript`
- 🟢 [Runtipi](https://github.com/runtipi/runtipi) - 个人家庭服务器，一条命令安装，一键部署应用。 `TypeScript`

---

## 📊 监控

了解服务是否在线、服务器是否健康的工具。

- 🟢 [monitor-stack](https://github.com/0x10debug/monitor-stack) - 轻量监控栈：可用性、服务器指标、Docker 状态、安全告警一体化部署。 `Shell`
- 🟢 [Uptime Kuma](https://github.com/louislam/uptime-kuma) - 精美的自托管可用性监控，90+ 通知渠道和状态页。 `JavaScript`
- 🟢 [Beszel](https://github.com/henrygd/beszel) - 轻量服务器监控，历史数据、Docker 状态、告警。 `Go`
- 🟢 [Netdata](https://github.com/netdata/netdata) - 实时基础设施监控，每秒指标和 ML 异常检测。 `C`
- 🟢 [Grafana](https://github.com/grafana/grafana) + [Prometheus](https://github.com/prometheus/prometheus) - 专业指标和仪表盘。功能强大但资源消耗大。 `Go`
- 🟢 [哪吒探针](https://github.com/nezhahq/nezha) - 多服务器监控面板，中文 VPS 社区流行。 `Go`

---

## 💾 备份与恢复

确保数据在灾难中存活下来的工具。

- 🟢 [backup-kit](https://github.com/0x10debug/backup-kit) - VPS 预配置备份策略：加密、自动化、恢复演练、Docker volume 支持。 `Shell`
- 🟢 [Restic](https://github.com/restic/restic) - 快速、安全、加密的备份工具，支持去重。服务器备份的 CLI 标杆。 `Go`
- 🟢 [Kopia](https://github.com/kopia/kopia) - 加密快照备份，带 Web 界面和多后端支持。 `Go`
- 🟢 [BorgBackup](https://github.com/borgbackup/borg) - 去重、压缩、带认证的备份。许多服务器备份工作流的底层引擎。 `Python`
- 🟢 [Borgmatic](https://github.com/borgmatic-collective/borgmatic) - BorgBackup 的 YAML 配置封装。声明式备份，集成 cron。 `Python`
- 🟢 [Duplicati](https://github.com/duplicati/duplicati) - 带 Web 界面的备份工具，支持多后端。 `C#`
- 🟢 [rclone](https://github.com/rclone/rclone) - 云存储瑞士军刀。同步、挂载、复制，支持 70+ 后端。 `Go`

---

## 🤖 AI 自托管

在自己的服务器上运行 AI 模型的工具。

- 🟢 [ai-workstation](https://github.com/0x10debug/ai-workstation) - VPS 上一键部署 AI 工作站：Ollama + Open WebUI，带反代、鉴权和模型管理。 `Shell`
- 🟢 [Ollama](https://github.com/ollama/ollama) - 本地运行 Llama、Mistral、Phi、Qwen 等模型。自托管 LLM 的标准方案。 `Go`
- 🟢 [Open WebUI](https://github.com/open-webui/open-webui) - ChatGPT 风格的 Ollama 和 OpenAI 兼容 API 前端。功能丰富，支持离线。 `Python`
- 🟢 [Lobe Chat](https://github.com/lobehub/lobehub) - 精美的多模型 AI 聊天，带插件生态。 `TypeScript`
- 🟢 [AnythingLLM](https://github.com/Mintplex-Labs/anything-llm) - 文档问答，集成向量存储和 RAG。 `JavaScript`
- 🟢 [vLLM](https://github.com/vllm-project/vllm) - 高吞吐 LLM 推理引擎。适合有 GPU 的服务器。 `Python`

---

## 🔍 审计与合规

检查服务器漏洞和合规性的工具。

- 🟢 [security-audit](https://github.com/0x10debug/security-audit) - CIS Benchmark 合规、漂移检测、容器扫描、自动修复——专为 VPS 设计。 `Shell`
- 🟢 [Lynis](https://cisofy.com/lynis/) - Linux/Unix 安全审计。详细的加固建议。 `Shell`
- 🟢 [Trivy](https://github.com/aquasecurity/trivy) - 容器镜像和文件系统漏洞扫描。 `Go`
- 🟡 [chkrootkit](http://www.chkrootkit.org/) - Rootkit 检测器。检查已知 rootkit 特征。 `C`
- 🟢 [CrowdSec Dashboard](https://app.crowdsec.net/) - 可视化 CrowdSec 拦截的攻击。威胁情报一目了然。 `Web`

---

## 🗃️ 归档 / 历史

曾经有用、但上游仓库现已归档的工具。保留在此供参考；请优先使用上方的活跃替代品。

- ⚫ [Homarr](https://github.com/ajnart/homarr) - 可定制的家庭服务器仪表盘，用于和 Docker 容器交互。上游已归档；可改用 [Homepage](https://github.com/gethomepage/homepage) 或 [Dashy](https://github.com/Lissy93/dashy)。 `TypeScript`

> 知道其他已归档的 VPS 工具？欢迎提 issue 或 PR。

---

## 🧩 0x10debug 生态

以下仓库由 [0x10debug](https://github.com/0x10debug) 账号维护，构成完整的 VPS 运营 + 安全工具链。每个都可组合使用：初始化服务器、加固、部署应用、监控、备份、审计——端到端覆盖。

- 🟢 [vps-security-enhancement-scripts](https://github.com/0x10debug/vps-security-enhancement-scripts) - VPS 安全加固脚本集（SSH、防火墙、内核、fail2ban/CrowdSec 基线）。
- 🟢 [vps-bootstrap](https://github.com/0x10debug/vps-bootstrap) - VPS 初始化 CLI：一条命令从裸机到加固、Docker 就绪的主机。
- 🟢 [compose-recipes](https://github.com/0x10debug/compose-recipes) - Docker Compose 部署套件，按自托管场景组织。
- 🟢 [network-toolkit](https://github.com/0x10debug/network-toolkit) - 网络配置模板库：反向代理、SSL、隧道、DDNS。
- 🟢 [monitor-stack](https://github.com/0x10debug/monitor-stack) - 监控栈：可用性、服务器指标、Docker 状态、安全告警。
- 🟢 [backup-kit](https://github.com/0x10debug/backup-kit) - 备份工具，预配置加密策略和恢复演练。
- 🟢 [security-audit](https://github.com/0x10debug/security-audit) - 深度安全审计：CIS Benchmark 检查、漂移检测、容器扫描、自动修复。
- 🟢 [ai-workstation](https://github.com/0x10debug/ai-workstation) - AI 工作站一键部署：Ollama + Open WebUI，带反代和鉴权。

它们共同覆盖完整的 VPS 生命周期：**初始化 → 加固 → 部署 → 监控 → 备份 → 审计**。

---

## 贡献指南

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
