---
name: purchase-service
description: Buy a TINO service through the MCP Gateway tools: browse the catalogue, order, read the invoice and obtain its payment link. Use for "mua hosting", "mua VPS", "đăng ký tên miền", "thanh toán hóa đơn" or buying a service.
---

# Buy a TINO service or pay an invoice

Use the MCP tools `find_gateway_operations` and `call_gateway_operation`; do not switch to a
browser or call the REST gateway directly.

## How to call an operation

1. Call `find_gateway_operations` with the canonical operation id below. Read the returned
   `parameters` and `body`; they contain the fields present in the registry contract. If a required
   nested shape is missing and this skill does not publish its exact shape, do not guess or
   call that operation.
2. If the operation is not returned, this client registration does not grant it. Report that
   refusal and stop; TINO must add both its operation and scope before the user reconnects.
   Reconnecting by itself cannot widen the grant.
3. Call `call_gateway_operation` with that `operation_id` and only the declared `path`, `query`
   and `body` fields. A read needs no `retry_key`.
4. Before an operation marked "changes state", show the price and order fields returned by the
   preceding reads, or the exact selected invoice impact, and get the user's explicit approval.
   Give it a new `retry_key`, and reuse that same key verbatim after an uncertain result; never
   submit the mutation again with a different key.

## Choose one request path

### Pay an existing invoice

Do not call any catalog or order operation. Read all pages of `billing.listInvoicesDue`, show the
returned invoice id, amount, currency and due date, and let the user select the exact invoice.
Continue with only that id.

### Buy a service or domain

Prepare exactly one item, then submit one `cart.order` with `{"items": [item]}`; specialized
order operations are outside this grant. The Gateway adds server-owned `is_frontend=true`; never
send or override that field.

For one hosting or VPS product, read its price and billing cycles with `cart.getProduct`. The item
shape is `{"type": "product", "product_id": <chosen product id>, "cycle": <chosen cycle>,
"custom": <chosen configuration>}`. For a domain, first call `cart.listDomainTldsV2`,
`domains.lookup` and `domains.getTldForm`, then use one item shaped as `{"type": "domain",
"name": <available full domain>, "years": <chosen period>, "action": "register", "tld_id":
<chosen TLD id>, "data": <required registration fields>}`. Omit optional fields instead of
inventing them, and stop if a required value is absent from those reads.

For `cart.order.body.items[].custom`, use the exact HostBill shape below. A `select` choice is
`{"<form.id>": {"<chosen item.id>": 1}}`: the inner literal `1` is HostBill's selection
marker even when that item's `value` is `null`. For another form type, mirror the exact inner
value shape already returned in `form.value`. Take ids only from the chosen `cart.getProduct`
result at `config.forms[].id` and `config.forms[].items[].id`; never invent an identifier or
substitute an item's title. If the desired non-select value or another required nested shape is
missing, stop rather than guess.

Before ordering, read all pages of `billing.listInvoicesDue` and retain every existing invoice
id. After the order, prefer an invoice id explicitly returned by the order response. If none is
returned, read all pages again and continue only when exactly one new invoice id is absent from
the snapshot. With zero or more than one candidate, stop and ask the user to verify the invoice;
never select the first result or attach a link to an unrelated pre-existing due invoice.

## The journey

### 1. Browse what can be bought

- `GET /api/v1/catalog/categories` -- `cart.listCategories`, scope `catalog:read`
- `GET /api/v1/catalog/category-tree` -- `cart.listCategoryTree`, scope `catalog:read`
- `GET /api/v1/catalog/categories/{category_id}/products` -- `cart.listProducts`, scope `catalog:read`
- `GET /api/v1/catalog/products/{product_id}` -- `cart.getProduct`, scope `catalog:read`

### 2. Prepare a domain registration

- `GET /api/v1/catalog/domain-tlds` -- `cart.listDomainTldsV2`, scope `catalog:read`
- `POST /api/v1/domains/availability` -- `domains.lookup`, scope `domains:read`
- `GET /api/v1/catalog/domain-tlds/{tld_id}/registration-fields` -- `domains.getTldForm`, scope `domains:read`

### 3. Snapshot due invoices before ordering

- `GET /api/v1/invoices/due` -- `billing.listInvoicesDue`, scope `billing:read`

### 4. Place exactly one order

- `POST /api/v1/orders` -- `cart.order`, scope `orders:write` (changes state)

### 5. Read the selected invoice

- `GET /api/v1/invoices/{invoice_id}` -- `billing.getInvoiceDetails`, scope `billing:read`

### 6. Get the payment link and wait

- `GET /api/v1/billing/payment-methods` -- `billing.listPaymentMethods`, scope `billing:read`
- `GET /api/v1/invoices/{invoice_id}/payment-links/{payment_method_id}` -- `billing.getPaymentLink`, scope `billing:pay`
- `POST /api/v1/invoices/actions/pay-due` -- `billing.payAllInvoices`, scope `billing:pay` (changes state)

## What paying means here

`billing.getPaymentLink` returns the link for one invoice and selected payment method.
`billing.payAllInvoices` is only for a user-confirmed grouped payment of selected due invoices; it
initiates the flow but moves no money on the user's behalf. Send the exact non-empty `selected`
invoice list the user confirmed; never send an empty body. Give the link from
`billing.getPaymentLink` to the user so they can complete payment themselves. Then poll
`billing.getInvoiceDetails` until the invoice status reads paid and report that status. On the buy
path, confirm the purchased service or domain in `infrastructure_inventory`; use
`account_infrastructure_overview` for the fuller picture where it is served, and start deployment
only for a deployable service the user just bought. On the existing-invoice path, stop after
reporting payment and never infer that a new service exists.
