---
name: deploy-project
description: Publish a project you are working on onto a TINO VPS or hosting account. Use when the user asks to deploy, publish or go live with code, an app or a site -- "deploy lên VPS", "đưa code lên hosting", "publish my app".
---

# Deploy a project onto TINO

AIM is only the connection and access layer. Read the project, choose its runtime, entry point,
build command and destination, then build and upload from this client. Never send source bytes,
artifacts, archives or an SSH private key to AIM.

## Choose and prepare the destination

Use the owned inventory to choose a VPS or cPanel account. Inspect the local project and build it
locally. Keep secrets and temporary credentials out of logs and project files.

## VPS

1. Create a new `ssh-ed25519` keypair locally for this access grant. Keep the private key local.
2. Call `request_deployment_access_approval` with `target_kind` set to `vps`, the owned
   `service_id`, `resource_id`, the public key and an `idempotency_key`.
3. Show the returned prompt to the user verbatim. Pass the user's own reply to
   `confirm_approval` as `user_response`.
4. Call `provision_vps_deploy_access` with the same service, resource and public key, the returned
   `approval_id` and an `idempotency_key`. Reuse that key for retries of this provision call.
5. Verify and pin the returned `host_key` before connecting. Use the matching private key with
   `rsync`, `scp` or SFTP directly from this client.
6. On a fresh Ubuntu 24.04 or 26.04 VPS, or one carrying an earlier TINO LEMP ready marker, read
   the MCP resource `tino://scripts/lemp-bootstrap-v2.sh` and run its contents unchanged through the
   pinned direct SSH connection before uploading. Do not assemble or substitute package commands,
   and do not copy the script from this skill. The script refuses another operating system or an
   existing unmanaged web stack. On any other existing VPS, preserve its stack.

The script installs the complete fixed deployment toolbox for static, PHP, Node.js and Python
projects, including Git, Composer, npm, archive and transfer tools, Certbot and its Nginx plugin.
After it returns `TINO_LEMP_READY`, do not install additional packages or repositories. Configure
and upload the application through the same direct SSH connection, including its database, systemd
unit, Nginx virtual host and TLS certificate when needed. The script does not configure SSH, a
firewall, application credentials, application files or migrations.

## cPanel

1. Call `request_deployment_access_approval` with `target_kind` set to `cpanel`, the owned
   `service_id`, `resource_id` and an `idempotency_key`.
2. Show the returned prompt to the user verbatim and pass the user's own reply to
   `confirm_approval`.
3. Call `provision_cpanel_deploy_access` with the same service and resource, the returned
   `approval_id` and an `idempotency_key`. Reuse that key for retries of this provision call.
4. The returned UAPI token has full account access. Call cPanel UAPI directly from this client;
   AIM does not proxy uploads. Constrain every path to the chosen document root, create a
   restorable backup before overwriting files, handle AutoSSL through UAPI, verify the public
   site and restore the backup if verification fails.

## Finish

After the destination serves correctly, use `ensure_domain_dns` for an owned apex domain. For a
subdomain, call `configure_dns` with the owned apex zone in `domain` and the subdomain in the
record's `name`.
Stop using every credential at `expires_at`; remove the temporary local private key or token when
finished. Request a new approval if the target, public key or expiry changes.
