# Tino Connector

Connect your AI agent or IDE to your TINO account over Remote MCP with OAuth
consent. The agent talks only to `https://aim.tino.vn/mcp`; you sign in and
approve scopes in your own browser, and you can revoke the connection any time
from your TINO account portal.

This public repository contains the installers, connector packages, and seven
skills shipped with Tino Connector. What you inspect at
[github.com/tinovn/tino-connector](https://github.com/tinovn/tino-connector)
is what the installers use. Please send feedback to support@tino.vn.

## What you can do after connecting

Tino Connector gives your AI agent TINO-aware skills plus the Remote MCP tools
needed to carry them out. It does not add a separate management screen: open
the normal agent or chat for your project and describe the result you want.

| Capability | What the agent can do |
| --- | --- |
| **Account and billing** | Read your account profile, phone-verification status, approved scopes, service summary, and due invoices when available. |
| **Hosting, VPS, and domains** | List the services you already own, including status, product, billing cycle, renewal or expiry date, and deployment readiness. |
| **Website diagnosis** | Run DNS and HTTP checks from your computer, then compare the public result with your TINO domain, service, suspension, and invoice status. |
| **Deployment recommendation** | Inspect the project locally, reuse an existing service when suitable, and recommend shared hosting for static/PHP/WordPress workloads or a VPS for Node.js, Python, containers, workers, and root-level requirements. |
| **Purchase services and domains** | Browse the TINO catalog and billing cycles, check domain availability and registration fields, present the price for approval, create the confirmed order, retrieve its invoice and payment link, and verify activation after payment. |
| **Deploy from your computer** | Request expiring VPS or cPanel access, then let your local agent build and upload the project directly. Fresh Ubuntu 24.04 or 26.04 VPS instances can use the maintained TINO LEMP bootstrap before application setup. |
| **DNS and go-live** | Plan and apply supported records for an owned apex domain or subdomain, point it to the deployed service, and verify the public DNS result. External DNS stays under your control and receives manual instructions instead. |

The bundled skills teach the agent how to choose and sequence these workflows.
MCP tools perform only the account operations that your current connection is
allowed to use.

## Start using Tino Connector

After installation and browser consent, start a normal task in your supported
AI client. You can ask in Vietnamese or English; no command syntax is required.

Example prompts in Vietnamese:

- `Kiểm tra trạng thái tài khoản TINO và số điện thoại đã xác minh chưa.`
- `Liệt kê toàn bộ hosting, VPS, domain và ngày gia hạn của tôi.`
- `Tôi còn hóa đơn nào chưa thanh toán?`
- `Chẩn đoán vì sao example.com không truy cập được.`
- `Project này nên deploy lên hosting hay VPS? Ưu tiên dịch vụ tôi đang có.`
- `Tìm VPS 4 GB RAM và báo giá theo tháng, chưa đặt mua.`
- `Kiểm tra tino-example.io.vn còn trống không và báo phí một năm.`
- `Deploy project hiện tại lên VPS của tôi rồi trỏ staging.example.com.`
- `Đây là WordPress. Hãy deploy lên hosting đang có và backup trước khi ghi đè.`
- `VPS này mới tinh. Chạy TINO LEMP bootstrap rồi deploy Laravel và cấu hình Nginx/TLS.`
- `Cho tôi xem kế hoạch trỏ app.example.com về 203.0.113.10, chưa áp dụng.`

Example prompts in English:

- `List my TINO services and their renewal dates.`
- `Diagnose why example.com is unavailable.`
- `Recommend hosting or VPS for this project and reuse what I own if possible.`
- `Find a suitable VPS and show the monthly price. Do not order yet.`
- `Deploy this project to my VPS and point staging.example.com to it.`

For a changing operation, the agent should first show the exact target and
impact, then wait for your confirmation. You may also state a boundary such as
`plan only`, `do not order yet`, or `do not change DNS` in the request.

## How deployment works

1. Your local AI agent reads the project, detects its runtime, entry point and
   build steps, and chooses a suitable destination. This analysis is not an AIM
   server task.
2. The agent checks your TINO inventory, proposes a deployment plan, and asks
   for confirmation before provisioning access or changing live infrastructure.
3. For a VPS, the agent creates an SSH key pair on your computer and submits
   only the public key. AIM installs that public key temporarily and returns the
   host, port, username, pinned host-key details, fingerprint, and `expires_at`.
   For cPanel, AIM returns an expiring approved UAPI token and hostname.
4. The agent uses those credentials from your computer to upload by SSH,
   `rsync`, SFTP, or cPanel UAPI. A fresh supported VPS can first run the
   canonical `tino://scripts/lemp-bootstrap-v2.sh` resource, then receive the
   application, database, process, Nginx, and TLS configuration it needs.
5. The agent checks the deployed application and public endpoint, applies an
   approved DNS plan when requested, and reports success or rolls back a failed
   change where the workflow supports it.

AIM never receives your source code or SSH private key. AIM is the connection
and authorization layer; your AI client reads, builds, uploads, verifies, and
repairs the code directly from your computer.

## Purchasing and payment

The purchase skill can discover currently allowed catalog, domain, order,
invoice, and payment operations instead of guessing API parameters. A normal
purchase flow is:

1. Browse products, billing cycles, TLD prices, or domain availability.
2. Show the selected item, price, registration details, and expected effect.
3. Wait for your explicit confirmation, then create one order through
   `cart.order`.
4. Retrieve the resulting invoice, available payment methods, and payment link.
5. You complete payment yourself on the returned TINO payment page.
6. The agent checks the invoice status and confirms that the new service or
   domain appears in your inventory.

The connector does not transfer money on your behalf and does not switch to an
unapproved browser or REST flow to bypass a missing operation or permission.

## Safety, permissions, and limits

- Sign-in and scope consent happen on the TINO website in your browser. Do not
  paste your TINO password, OAuth token, SSH private key, or cPanel token into
  chat.
- Read-only checks can run directly. Deployment access, orders, payment-flow
  initiation, and live DNS changes require confirmation of the concrete target
  and impact.
- VPS keys and cPanel tokens are short-lived. The agent must stop using them at
  `expires_at` and remove temporary local credentials when the task finishes.
- Available actions depend on the scopes you approve and the tools exposed to your client.
  Reconnecting does not silently add broader permissions; approve a new grant
  when a required scope is missing.
- DNS diagnosis uses public DNS plus available TINO domain and service details;
  it does not promise access to every record inside a hosted DNS zone.
- Nameserver updates are available only when the current connection explicitly
  exposes the matching tool and `domains:write` permission. Otherwise the agent
  should present the required manual change.
- You can revoke the connection from your TINO account portal at any time.

## One-command install

macOS or Linux:

```bash
curl -fsSL https://aim.tino.vn/connect | bash
```

Windows PowerShell:

```powershell
irm https://aim.tino.vn/install.ps1 | iex
```

Windows Command Prompt can download and run
[`install.cmd`](https://github.com/tinovn/tino-connector/blob/main/install.cmd),
which opens the same PowerShell menu.

Both `aim.tino.vn` installer URLs serve the matching scripts from this public
repository, so the source shown here is the source that runs.

The menu covers Claude Code, VS Code, Cursor, Codex, Zed, Hermes Agent, and a
manual Remote MCP option. If you download a script first, you can select
clients without the menu, for example `bash install.sh claude codex hermes` or
`.\install.ps1 claude codex hermes`. The installers call each client's official
plugin command or add the Remote MCP declaration; they do not install `tino`
CLI and do not ask for a TINO password or token. OAuth sign-in and consent
happen in your browser.

## Claude Code

```
/plugin marketplace add tinovn/tino-connector
/plugin install tino-connect@tino
```

Then run `/mcp`, pick `tino-connect`, and sign in when the browser opens.
CLI equivalent: `claude plugin marketplace add tinovn/tino-connector` and
`claude plugin install tino-connect@tino`.

## VS Code

Install **Tino Connector** from the Visual Studio Marketplace
(`tinovn.aim-connector-vscode`), then sign in from the status bar.

## Codex

```bash
codex plugin marketplace add tinovn/tino-connector
codex plugin add tino-connect@tino
```

Start a new task. Codex loads the Remote MCP server and all seven skills from
the plugin, then opens TINO OAuth when access is first needed.

## Hermes Agent

```bash
hermes plugins install tinovn/tino-connector --enable
```

Restart Hermes Agent, then authenticate the saved connection with
`hermes mcp login tino-connect`. The browser opens for TINO sign-in and
consent; after that Hermes loads the Remote MCP tools and the same seven
skills. Later updates replace the plugin and skills together with
`hermes plugins update tino-connect`.

## Manual Remote MCP

Any client that accepts a Remote MCP declaration can use:

```json
{"mcpServers":{"tino-connect":{"type":"http","url":"https://aim.tino.vn/mcp"}}}
```

This only tells the client where Tino Connector is. The client performs OAuth
in your browser; no TINO credential belongs in this JSON.

## Other MCP clients

See [packages/tino-connect/SETUP.md](packages/tino-connect/SETUP.md) for the
per-client configuration blocks for Cursor, Antigravity and any client that
accepts a Remote MCP declaration.

## Zed

The [zed/](zed/) directory carries the Zed server declaration and agent
skills. Until the extension is available from the Zed registry, copy
`zed/server.json` into your Zed MCP settings and the `zed/.agents/skills/`
directory into your project.

## What is inside

- Repository root — the native Hermes Agent plugin and its seven skills.
- `packages/tino-connect/` — the Claude Code and Codex plugin: MCP declaration,
  seven skills (account status, list services, diagnose website, recommend
  deployment, deploy service, deploy project, purchase service), setup guide.
- `.agents/plugins/marketplace.json` — the native Codex marketplace.
- `zed/` — the Zed hand-off assets.
- Apache-2.0 licensed. Support: support@tino.vn
