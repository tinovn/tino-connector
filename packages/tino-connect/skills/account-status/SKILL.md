---
name: account-status
description: Check the authenticated TINO account status and due invoices. Use when the user asks about their TINO account, unpaid bills, "tình trạng tài khoản" or "hóa đơn chưa thanh toán".
---

# TINO account status

Read the tool list you were handed at connection time and take the first
branch it carries. Both end in the same report.

## `account_infrastructure_overview` (optional workflow tool, one call)

Read from `structuredContent.data`: the profile summary first, then the due
invoices with amount, currency and due date exactly as returned -- never
convert currency.

## Otherwise, the always-served reads

1. `get_account_profile` -- `email`, `display_name`, `company_name` and the
   `phone` block, whose `status` says where phone verification stands. Reach
   for `get_account_security_status` instead only when phone verification is
   the entire question; it returns that same block on its own.
2. `account_status` -- the plan-visible `status`, the granted `scopes` and
   the `service_count` / `domain_count` behind them.
3. `infrastructure_inventory` when the user wants the services those counts
   stand for; the list-services skill covers reading them.

When the overview is absent and invoices matter, use `find_gateway_operations`
for `billing.listInvoicesDue`, then `call_gateway_operation` with only the
returned fields. If either tool or operation is absent, report that this
connection cannot read invoices. Never switch to a browser or REST, and never
infer an unpaid bill from a service `status`.

An empty section means "none", not "unknown"; say so plainly. On `isError`,
report the returned `code` and `remediation` verbatim and stop.
