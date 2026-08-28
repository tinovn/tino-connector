---
name: diagnose-website
description: "Diagnose why a website on TINO infrastructure is unreachable or misconfigured. Use when a site is down or DNS looks wrong — \"website bị lỗi\", \"không truy cập được\", \"DNS sai\"."
---

# Diagnose a website

1. Local probes first, with your own shell (no TINO auth involved):
   `dig +short NS <domain>`, `dig +short A <domain>`, and
   `curl -sSI --max-time 10 <site-url>` over HTTPS. These always work and are
   the backbone of the diagnosis.
2. Read the TINO side. Take the branch the tool list you were handed carries:
   - `inspect_domain_dns` (optional workflow tool) with the bare domain name:
     registrar `nameservers` and `managed_dns` in one read-only call.
   - Otherwise, always served: `infrastructure_inventory` to find the domain
     and its `domain_id`, then `inspect_domain` with that `domain_id` for its
     `nameservers`. `inspect_service` with the owning `service_id` reports the
     service `status` and `blocked_reason`.
3. Compare the registrar `nameservers` against the `dig NS` answer. Neither
   branch returns zone records, so the `dig A` answer is your only address
   evidence -- report the zone contents as unread instead of guessing them.
   `managed_dns=false` says only that TINO does not host the zone.
4. If the site resolves but errors, look for a billing or suspension cause:
   `account_infrastructure_overview` carries the due invoices where it is
   served; otherwise the service `status` and `blocked_reason` from step 2 are
   the first evidence. When invoices matter, use `find_gateway_operations`
   for `billing.listInvoicesDue`, then `call_gateway_operation` with only the
   returned fields. If unavailable, report that this connection cannot read
   invoices; never switch to a browser or REST.

Report each finding as symptom → evidence (command output or tool field) →
next action. A hypothesis without evidence is labeled a hypothesis. If the
fix is a nameserver change, hand over to the deploy-service skill; never
perform mutations from this skill.
