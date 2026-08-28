#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)
readme="$repo_root/README.md"

require_text() {
  local text=$1
  grep -Fq -- "$text" "$readme" || {
    printf 'README capability contract is missing: %s\n' "$text" >&2
    exit 1
  }
}

require_text '## What you can do after connecting'
require_text '## Start using Tino Connector'
require_text '## How deployment works'
require_text '## Purchasing and payment'
require_text '## Safety, permissions, and limits'

require_text 'Account and billing'
require_text 'Hosting, VPS, and domains'
require_text 'Website diagnosis'
require_text 'Deployment recommendation'
require_text 'Purchase services and domains'
require_text 'Deploy from your computer'
require_text 'DNS and go-live'

require_text 'Liệt kê toàn bộ hosting, VPS, domain và ngày gia hạn của tôi.'
require_text 'Deploy project hiện tại lên VPS của tôi rồi trỏ staging.example.com.'
require_text 'AIM never receives your source code or SSH private key.'
require_text 'You complete payment yourself on the returned TINO payment page.'
require_text 'Available actions depend on the scopes you approve and the tools exposed to your client.'
require_text 'live DNS changes require confirmation of the concrete target'
require_text 'External DNS stays under your control and receives manual instructions instead.'

printf 'readme_capability_contract_ok\n'
