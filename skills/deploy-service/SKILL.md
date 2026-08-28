---
name: deploy-service
description: "Point a domain at an existing TINO service: check readiness, then change its DNS records or its nameservers. Use for \"trỏ tên miền\", \"đưa website lên TINO\", pointing a domain, or post-deploy checks."
---

# Point a domain at a TINO service

This skill covers readiness and DNS. Publishing the source itself is the
deploy-project skill; come back here to point the domain.

1. Preflight. `infrastructure_inventory` is always served and is where the
   `domain_id` step 3 requires comes from, alongside each service's
   `service_id` and `status`; `inspect_domain` with that `domain_id` reads the
   registrar `nameservers`. `account_infrastructure_overview` (service state)
   and `inspect_domain_dns` (registrar view) are optional workflow tools — a
   deployment serves them only when it enables the Gateway workflows, so read
   the tool list you were handed at connection time. Your own shell always
   works: `dig +short NS <domain>` and `dig +short A <domain>` read the live
   delegation and address. Record both — they are the rollback.
2. The source is published by the deploy-project skill, or by the service's
   own tooling; check it with `curl -sSI` against the service hostname
   before touching DNS.
3. Point the domain. Two tools do this and both are always served. Each is
   declared destructive: plan first, show the user the domain, what resolves
   now and what you propose, and get a fresh, explicit confirmation for this
   exact change before you apply anything.
   - `ensure_domain_dns` handles an owned apex domain. Pass `domain`, its
     `domain_id`, `expected_ipv4`, `target_kind` and an `idempotency_key`.
     A cPanel target also requires its `service_id` and `resource_id`; a VPS
     target accepts neither. Leave `apply` false first. If the result is
     `dns_confirmation_required`, relay `confirmation.prompt` verbatim and
     call `confirm_approval` with `confirmation.reference` and the user's
     reply. Then call again with `apply` true, `cutover_decision` set to
     `approve`, the returned `approval_id`, and the same inputs and
     `idempotency_key`. For a non-destructive `dns_plan`, or a destructive
     plan whose `incumbent_web` is `no_response`, get the client's explicit
     confirmation and call again with `apply` true and no `approval_id`.
     `manual_dns_required` means the authoritative DNS is external: report
     the required A record and stop. For `support_ticket_required`, show the
     user that cPanel automation needs support; after confirmation call the
     same request with `apply` true to receive `support_ticket_created` or
     `support_ticket_existing`.
   - `configure_dns` edits records inside one owned zone. Pass the owned apex
     as `domain`; a record's `name` may be a subdomain. `records` defines only
     the `(name, type)` slots it names, and `prune` removes other answers only
     inside those named slots. Plan with `apply` false. Apply a direct plan
     only when `destructive` is false; arbitrary destructive direct plans have
     no public approval issuer, so stop when `approval_required` is true.
4. Handing the domain to different nameservers — a delegation change, not a
   record edit — is `update_domain_nameservers`, an optional workflow tool.
   When the tool list carries it: read `references/nameserver-cutover.md`
   first, get the same explicit confirmation, then call it with the domain,
   the nameserver hostnames and a new `workflow_retry_key`. Keep the key;
   reuse it verbatim only to retry the identical request. When it is absent,
   a delegation change is the user's to make on tino.vn — say so.
5. Check the result yourself with `dig +short NS <domain>` and
   `dig +short A <domain>`, and tell the user propagation may lag.
