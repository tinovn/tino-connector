#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)
fake_bin=$(mktemp -d)
log_file=$(mktemp)
trap 'rm -rf "$fake_bin" "$log_file"' EXIT

cat >"$fake_bin/hermes" <<'SH'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$HERMES_TEST_LOG"

case "$*" in
  "plugins install tinovn/tino-connector --enable") exit 0 ;;
  "config get mcp_servers.tino-connect.url") exit 1 ;;
  *) exit 0 ;;
esac
SH
chmod +x "$fake_bin/hermes"

PATH="$fake_bin:$PATH" HERMES_TEST_LOG="$log_file" bash "$repo_root/install.sh" hermes >/dev/null

expected=$(cat <<'EOF'
plugins install tinovn/tino-connector --enable
config get mcp_servers.tino-connect.url
config set mcp_servers.tino-connect.url https://aim.tino.vn/mcp
config set mcp_servers.tino-connect.auth oauth
config set mcp_servers.tino-connect.strict_redirect_headers true
mcp login tino-connect
EOF
)
actual=$(cat "$log_file")

if [[ "$actual" != "$expected" ]]; then
  printf 'Hermes install command sequence differs.\nExpected:\n%s\nActual:\n%s\n' \
    "$expected" "$actual" >&2
  exit 1
fi

printf 'install_test_ok\n'
