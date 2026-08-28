# Tino Connector

Connect your AI agent or IDE to your TINO account over Remote MCP with OAuth
consent. The agent talks only to `https://aim.tino.vn/mcp`; you sign in and
approve scopes in your own browser, and you can revoke the connection any time
from your TINO account portal.

This public repository contains the installers, connector packages, and seven
skills shipped with Tino Connector. What you inspect at
[github.com/tinovn/tino-connector](https://github.com/tinovn/tino-connector)
is what the installers use. Please send feedback to support@tino.vn.

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
