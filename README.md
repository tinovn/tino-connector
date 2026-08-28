# Tino Connector

Connect your AI agent or IDE to your TINO account over Remote MCP with OAuth
consent. The agent talks only to `https://aim.tino.vn/mcp`; you sign in and
approve scopes in your own browser, and you can revoke the connection any time
from your TINO account portal.

This repository holds the manually installable packages. All content is
generated from the TINO product source; changes ship as new versions here, so
please send feedback to support@tino.vn instead of pull requests.

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
(`tinovn.aim-connector-vscode`) or from OpenVSX, then sign in from the status
bar.

## Codex and other MCP clients

See [packages/tino-connect/SETUP.md](packages/tino-connect/SETUP.md) for the
per-client configuration blocks (Codex `config.toml`, Cursor, Antigravity, and
the plain `.mcp.json` declaration any Remote MCP client accepts).

## Zed

The [zed/](zed/) directory carries the Zed server declaration and agent
skills. Until the extension is available from the Zed registry, copy
`zed/server.json` into your Zed MCP settings and the `zed/.agents/skills/`
directory into your project.

## What is inside

- `packages/tino-connect/` — the agent plugin: MCP server declaration,
  seven skills (account status, list services, diagnose website, recommend
  deployment, deploy service, deploy project, purchase service), setup guide.
- `zed/` — the Zed hand-off assets.
- Apache-2.0 licensed. Support: support@tino.vn
