# Setting up TINO Connect

## With the plugin

1. Install this plugin.
2. The client loads the `tino-connect` MCP server and all seven skills automatically; there is no MCP file or skill copy step.
3. Sign in when the client opens https://aim.tino.vn and approve the requested scopes. Revoke the grant any time from your TINO account portal.
4. A Git marketplace update replaces the plugin and its skills together under the same version.

## By hand, without the plugin

The plugin only declares one remote server. Any client that speaks Remote MCP over HTTP can declare it itself; sign-in and consent then happen exactly as above.

### Claude Code

Either run

    claude mcp add --transport http tino-connect https://aim.tino.vn/mcp

or put this in the project's `.mcp.json` (it is the file this plugin ships):

    {"mcpServers":{"tino-connect":{"type":"http","url":"https://aim.tino.vn/mcp"}}}

### Codex

Codex reaches TINO through the installed `tino` command-line client, which bridges its standard input to the same remote server. Install the CLI, run `tino login` once, then add to `~/.codex/config.toml`:

    [mcp_servers.tino-connect]
    command = "tino"
    args = ["mcp"]

### VS Code, Cursor and Antigravity

VS Code users install the TINO Connect VSIX, which includes Device sign-in, Remote MCP and the same seven skills with no settings. Cursor and Antigravity can use the JSON block above when their native Remote MCP OAuth supports the AIM authorization flow; otherwise use the installed `tino mcp` bridge.

Support: support@tino.vn
