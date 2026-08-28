# TINO Connect

Operate your TINO account and services from an AI agent over Remote MCP with OAuth consent.

The agent talks only to the Remote MCP endpoint at https://aim.tino.vn/mcp; no CLI install and no server sign-in details are involved. Deploying, repairing and changing DNS all change something; every such tool is declared destructive or not-read-only so the client can request confirmation. Deployment access and destructive apex DNS changes also use AIM's explicit approval ceremony.

## Optional workflow tools

Served only where the deployment enables the Gateway workflows. The skills say what to do when they are absent.

- `account_infrastructure_overview`: One overview of the authenticated account: profile summary, active services, domains and due invoices.
- `inspect_domain_dns`: Inspect one domain by name: registration state, nameservers and the managed DNS zone when one exists.
- `update_domain_nameservers`: Replace one domain's nameservers and read them back to verify. Changes public DNS delegation; idempotent under a caller-held retry key. Declared destructive, which is a hint the client acts on: confirming with the user is the client's job, and AIM does not gate the call behind one.

## Skills

account-status, list-services, diagnose-website, recommend-deployment, deploy-service, deploy-project, purchase-service — see `skills/`.

Support: support@tino.vn
