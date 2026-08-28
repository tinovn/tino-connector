# Set up Tino Connect in Hermes Agent

1. Install and enable the plugin:

       hermes plugins install tinovn/tino-connector --enable

2. Restart Hermes Agent so the enabled plugin loads.
3. Start OAuth for the saved Remote MCP connection:

       hermes mcp login tino-connect

   Hermes opens https://aim.tino.vn for sign-in and consent.
4. Start a TINO request; the Remote MCP tools and all seven packaged skills are now available.

Update the connector and skills together with:

    hermes plugins update tino-connect

Support: support@tino.vn
