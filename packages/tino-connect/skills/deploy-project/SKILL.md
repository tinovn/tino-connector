---
name: deploy-project
description: Publish a project you are working on onto a TINO VPS or hosting account. Use when the user asks to deploy, publish or go live with code, an app or a site -- "deploy lên VPS", "đưa code lên hosting", "publish my app".
---

# Deploy a project onto TINO

AIM is only the connection and access layer. Read the project, choose its runtime, entry point,
build command and destination, then build and upload from this client. Never send source bytes,
artifacts, archives or an SSH private key to AIM.

## Choose and prepare the destination

One call to `infrastructure_inventory` decides everything. It already states the type of each
service, so never infer it from a product name, a price or a domain:

- `kind` is `vps`, `hosting`, or `other`. `vps` takes the VPS steps below, `hosting` takes the
  cPanel steps. `other` means upstream did not state a type -- ask the user which it is rather
  than guessing, and never assume it is a VPS because it has no cPanel look to it.
- `deployable` says whether that service can receive a deployment at all. When it is `false`, show
  `blocked_reason` to the user and do not request access for it -- a cancelled or suspended
  service will refuse.
- `service_id` is what every access call takes.

That is the whole classification step. Then, and only for the two things the inventory does not
carry:

- **VPS**: call `inspect_service` to read `vms[].vm_id`, which is the `resource_id` the access
  calls need. A VPS with an empty `vms` list has no machine to deploy to yet.
- **cPanel**: call nothing. The `resource_id` is the `service_id` itself.

Do not call `inspect_service` on a hosting service to find out what it is: it answers with an
empty `vms` list because hosting has no virtual machines, which is the correct answer and not a
signal about the service.

Inspect the local project and build it locally. Keep secrets and temporary credentials out of logs
and project files.

Send one new opaque `idempotency_key` per approval request. Reuse a key only to retry the identical
provision call.

On `AUTH_REQUIRED`, or "Authentication required", this connection's authority is gone: ask the user
to sign in again through this client and stop. Never retry the call, open a browser or call REST.

## VPS

1. Create the keypair locally with `ssh-keygen -t ed25519 -N '' -f <path>` and keep the private key
   local. Send the public key as the single line `ssh-ed25519 <base64> [comment]`; options, an RSA
   key or extra whitespace are refused.
2. Call `request_deployment_access_approval` with `target_kind` set to `vps`, the owned
   `service_id`, `resource_id` set to that service's `vm_id` from `inspect_service`, the public key
   and a new `idempotency_key`.
3. Show the returned prompt to the user verbatim. Pass the user's own reply to
   `confirm_approval` as `user_response`.
4. Call `provision_vps_deploy_access` with the same service, resource and public key, the returned
   `approval_id` and an `idempotency_key`. Reuse that key for retries of this provision call; a new
   key against the same approval re-installs the same public key, which is allowed until
   `expires_at`.
5. The returned `host_key` is one OpenSSH public-key line, `<type> <base64>`. Write
   `<host> <that line>` — `[<host>]:<port> <that line>` for a port other than 22 — into a
   known_hosts file and connect with `StrictHostKeyChecking=yes`. Use the matching private key with
   `rsync`, `scp` or SFTP directly from this client.
6. The TINO marker is the file `/var/lib/tino-vibe-kit/lemp-v2.ready`. Whenever that marker is
   absent on Ubuntu 24.04 or 26.04, read the MCP resource `tino://scripts/lemp-bootstrap-v2.sh`
   and run its contents unchanged through the pinned direct SSH connection before uploading; the
   script guards itself, and refuses another operating system or an existing unmanaged web stack.
   Do not assemble or substitute package commands, and do not copy the script from this skill. On
   any other existing VPS, preserve its stack.

The script installs the complete fixed deployment toolbox for static, PHP, Node.js and Python
projects, including Git, Composer, npm, archive and transfer tools, Certbot and its Nginx plugin.
After it returns `TINO_LEMP_READY`, do not install additional packages or repositories;
language-level dependencies (`npm ci`, `composer install`, `pip install` into a virtualenv) are
expected. Nginx carries no server block for the site, so write its virtual host before any public
health check. Configure and upload the application through the same direct SSH connection,
including its database, systemd unit, Nginx virtual host and TLS certificate when needed. The
script does not configure SSH, a firewall, application credentials, application files or
migrations.

## cPanel

1. Call `request_deployment_access_approval` with `target_kind` set to `cpanel`, the owned
   `service_id`, and `resource_id` set to that same `service_id` — the server refuses any other
   pair — and a new `idempotency_key`.
2. Show the returned prompt to the user verbatim and pass the user's own reply to
   `confirm_approval`.
3. Call `provision_cpanel_deploy_access` with the same service and resource, the returned
   `approval_id` and an `idempotency_key`. Reuse that key for retries of this provision call; the
   same target returns the same token until it expires.
4. The returned UAPI token has full account access. Call cPanel UAPI directly from this client;
   AIM does not proxy uploads. Constrain every path to the chosen document root, create a
   restorable backup before overwriting files, handle AutoSSL through UAPI, verify the public
   site and restore the backup if verification fails.

## Finish

After the destination serves correctly, use `ensure_domain_dns` for an owned apex domain. For a
subdomain, call `configure_dns` with the owned apex zone in `domain` and the subdomain in the
record's `name`. `configure_dns` creates records and updates them non-destructively; replacing or
deleting a live answer needs an approval no tool issues today, so stop and tell the user to make
that change on tino.vn.
Stop using every credential at `expires_at`; remove the temporary local private key or token when
finished. Request a new approval if the target, public key or expiry changes.
