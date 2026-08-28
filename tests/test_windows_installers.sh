#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)

require_text() {
  local file=$1
  local text=$2
  grep -Fq -- "$text" "$file" || {
    printf 'missing text in %s: %s\n' "$file" "$text" >&2
    exit 1
  }
}

reject_text() {
  local file=$1
  local text=$2
  if grep -Fiq -- "$text" "$file"; then
    printf 'forbidden legacy command in %s: %s\n' "$file" "$text" >&2
    exit 1
  fi
}

ps1="$repo_root/install.ps1"
cmd="$repo_root/install.cmd"
readme="$repo_root/README.md"

test -f "$ps1"
test -f "$cmd"

require_text "$ps1" 'https://aim.tino.vn/mcp'
require_text "$ps1" 'claude plugin marketplace add'
require_text "$ps1" 'code --install-extension'
require_text "$ps1" 'codex plugin marketplace add'
require_text "$ps1" 'hermes plugins install'
require_text "$ps1" '"mcpServers"'
require_text "$cmd" 'https://aim.tino.vn/install.ps1'

reject_text "$ps1" 'tino login'
reject_text "$ps1" 'tino mcp'
reject_text "$cmd" 'tino login'
reject_text "$cmd" 'tino mcp'

require_text "$readme" 'curl -fsSL https://aim.tino.vn/connect | bash'
require_text "$readme" 'irm https://aim.tino.vn/install.ps1 | iex'
require_text "$readme" '{"mcpServers":{"tino-connect":{"type":"http","url":"https://aim.tino.vn/mcp"}}}'
require_text "$readme" 'https://github.com/tinovn/tino-connector'

printf 'windows_installer_contract_ok\n'
