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

Install the public marketplace and its plugin:

    codex plugin marketplace add tinovn/tino-connector
    codex plugin add tino-connect@tino

Codex then loads the same Remote MCP declaration and all seven skills from the plugin. Start a new task and complete OAuth in the browser when prompted.

### VS Code, Cursor and Antigravity

VS Code users install the TINO Connect VSIX, which includes Device sign-in, Remote MCP and the same seven skills with no settings. Cursor and Antigravity can use the JSON block above when their native Remote MCP OAuth supports the AIM authorization flow.

### Hermes Agent

Install the native plugin from its public Git repository:

    hermes plugins install tinovn/tino-connector --enable

Restart Hermes Agent, then authenticate the saved Remote MCP connection:

    hermes mcp login tino-connect

Hermes loads the OAuth Remote MCP server and all seven skills from the same plugin. The login command opens https://aim.tino.vn for sign-in and consent; the plugin stores no TINO password or token. Update the runtime and skills together with:

    hermes plugins update tino-connect

Support: support@tino.vn
