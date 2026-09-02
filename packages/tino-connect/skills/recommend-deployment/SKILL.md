---
name: recommend-deployment
description: "Recommend which TINO service fits a workload before deploying. Use when the user asks where to host an app or site — \"nên dùng gói nào\", \"chọn hosting hay VPS\"."
---

# Recommend a TINO deployment target

1. Read what the account already owns, then prefer reusing a suitable
   existing service over proposing a new purchase. Take the branch the tool
   list you were handed carries:
   - `account_infrastructure_overview` (optional workflow tool), one
     read-only call.
   - Otherwise `infrastructure_inventory`, always served: each service's
     `kind`, `status`, `product_name` and `deployable`, plus the account's
     `domains`.
   That one list already classifies every service. `kind` is `hosting`,
   `vps`, `domain` or `other`, taken from what upstream states about the
   product, so do not re-derive it from `product_name`, price or domain:
   names like `WH 1` say nothing, and `Platinum Hosting` is hosting while
   `NVMe VPS` is a VPS regardless of how either is worded. `other` means
   upstream stated no type -- ask the user rather than assuming. Call
   `inspect_service` only to read a VPS's `vms`, never to find out what a
   service is.
2. Match the workload:
   - Static site or PHP/WordPress → shared hosting.
   - Custom runtime (Node, Python, containers), root access, or background
     workers → VPS.
   - The site needs a domain; note whether the account already holds one.
3. State one recommendation and the single deciding factor. If undecidable,
   name exactly which fact is missing.

This skill only recommends. Reuse an owned service by handing it to the deploy-project skill.
Hand over to purchase-service only when no suitable owned service exists and the user accepts
buying one; it discovers and calls the allowed purchase operations through MCP.
