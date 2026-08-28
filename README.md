# Tino Connector

Connect your AI agent or IDE to your TINO account over Remote MCP with OAuth
consent. The agent talks only to `https://aim.tino.vn/mcp`; you sign in and
approve scopes in your own browser, and you can revoke the connection any time
from your TINO account portal.

This repository holds the manually installable packages. Connector manifests
and skills are generated from the TINO product source; this launcher and guide
are maintained with each release. Please send feedback to support@tino.vn.

## Quick install

Use the native installer for your client below. If you downloaded this
repository from GitHub, `bash install.sh` opens one menu for Claude Code,
VS Code, Cursor, Codex, Zed and Hermes Agent. A non-interactive example is
`bash install.sh claude codex hermes`.

The repository deliberately does not recommend piping a remote download into
a shell. You can inspect `install.sh` before running it. Sign-in and consent
always happen in your own browser.

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
