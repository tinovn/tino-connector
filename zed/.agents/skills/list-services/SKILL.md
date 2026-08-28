---
name: list-services
description: "List the account's hosting, VPS and domain services with their billing cycle and next due date. Use for \"what services do I have\", renewal date questions, \"dịch vụ của tôi\", \"gia hạn dịch vụ\"."
---

# List TINO services

Read the tool list you were handed at connection time and take the first
branch it carries.

## `account_infrastructure_overview` (optional workflow tool, one call)

1. Present the services and domains sections as returned, with each
   service's billing cycle and next due date, plus the due-invoices section.
2. For a domain's registrar detail, call `inspect_domain_dns` with a domain
   name taken from step 1's output -- never with a free-form identifier the
   user typed.

## Otherwise, the always-served reads

1. `infrastructure_inventory` -- one read-only call returning `services`
   (`service_id`, `kind`, `label`, `status`, `product_name`, `domain`,
   `next_due`, `deployable`, `blocked_reason`) and `domains` (`domain_id`,
   `name`, `status`, `expires`, `autorenew`).
2. `inspect_service` with a `service_id` from step 1 for one service plus its
   `vms`.
3. `inspect_domain` with a `domain_id` from step 1 -- the identifier, not the
   name -- for one domain plus its `nameservers`.

Renewal facts on this branch come from `next_due` on each service and
`expires` / `autorenew` on each domain. For invoices, use
`find_gateway_operations` for `billing.listInvoicesDue`, then
`call_gateway_operation` with only the returned fields. If unavailable,
report that this connection cannot read invoices rather than inferring them.

Present everything neutrally; the decision to spend is the user's. There is
no dedicated upgrade skill. When the user asks to change a plan, discover the
relevant service operation with `find_gateway_operations` and use
`call_gateway_operation` only if it is returned; otherwise report the missing
grant. Missing data is reported as missing.
