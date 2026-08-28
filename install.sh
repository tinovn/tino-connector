#!/usr/bin/env bash
# Tino Connector — trình cài đặt một lệnh.
#
#   curl -fsSL https://raw.githubusercontent.com/tinovn/tino-connector/main/install.sh | bash
#
# hoặc chạy thẳng với tên client, bỏ qua menu:
#   bash install.sh claude vscode cursor codex zed manual
#
# Script chỉ khai báo máy chủ Remote MCP https://aim.tino.vn/mcp vào client bạn
# chọn. Không tải mã thực thi, không đụng tài khoản: đăng nhập + duyệt scope
# luôn diễn ra trong trình duyệt của bạn ở lần kết nối đầu. File cấu hình nào
# bị sửa đều được sao lưu thành *.bak.<thời-điểm> ngay cạnh.
set -u

MCP_URL="https://aim.tino.vn/mcp"
MARKETPLACE_REPO="tinovn/tino-connector"
PLUGIN_SPEC="tino-connect@tino"
VSIX_ID="tinovn.aim-connector-vscode"
MCP_JSON="{\"mcpServers\":{\"tino-connect\":{\"type\":\"http\",\"url\":\"$MCP_URL\"}}}"

say()  { printf '%s\n' "$*"; }
ok()   { printf '  ✔ %s\n' "$*"; }
warn() { printf '  ! %s\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }
backup() { [ -f "$1" ] && cp "$1" "$1.bak.$(date +%Y%m%d%H%M%S)" || true; }

install_claude() {
  say "== Claude Code"
  if ! have claude; then
    warn "chưa thấy lệnh 'claude' — cài Claude Code trước: https://claude.com/claude-code"
    return
  fi
  claude plugin marketplace add "$MARKETPLACE_REPO" >/dev/null 2>&1 || true
  if claude plugin install "$PLUGIN_SPEC" >/dev/null 2>&1; then
    ok "đã cài plugin $PLUGIN_SPEC"
  elif claude plugin update "$PLUGIN_SPEC" >/dev/null 2>&1; then
    ok "plugin đã có sẵn — vừa cập nhật lên bản mới nhất"
  else
    warn "không cài được tự động; chạy tay: claude plugin install $PLUGIN_SPEC"
    return
  fi
  ok "bước cuối: mở Claude Code, gõ /mcp, chọn tino-connect và đăng nhập"
}

install_vscode() {
  say "== VS Code"
  if have code; then
    if code --install-extension "$VSIX_ID" >/dev/null 2>&1; then
      ok "đã cài extension $VSIX_ID — đăng nhập từ thanh trạng thái"
      return
    fi
    warn "lệnh code chạy lỗi; cài tay từ Marketplace"
  else
    warn "chưa thấy lệnh 'code'"
  fi
  say "  → https://marketplace.visualstudio.com/items?itemName=$VSIX_ID"
}

install_cursor() {
  say "== Cursor"
  local f="$HOME/.cursor/mcp.json"
  if have python3; then
    backup "$f"
    mkdir -p "$HOME/.cursor"
    MCP_FILE="$f" MCP_URL="$MCP_URL" python3 - <<'PY'
import json, os
path = os.environ["MCP_FILE"]
data = {}
if os.path.exists(path):
    with open(path) as handle:
        data = json.load(handle)
data.setdefault("mcpServers", {})["tino-connect"] = {
    "type": "http",
    "url": os.environ["MCP_URL"],
}
with open(path, "w") as handle:
    json.dump(data, handle, indent=2)
PY
    ok "đã khai tino-connect vào $f — mở Cursor và đăng nhập khi được hỏi"
  else
    warn "không có python3 để gộp JSON an toàn; thêm tay vào $f:"
    say "  $MCP_JSON"
  fi
}

install_codex() {
  say "== Codex CLI"
  local f="$HOME/.codex/config.toml"
  if grep -qs 'mcp_servers.tino-connect' "$f"; then
    ok "config đã có sẵn khối tino-connect"
  else
    backup "$f"
    mkdir -p "$HOME/.codex"
    printf '\n[mcp_servers.tino-connect]\ncommand = "tino"\nargs = ["mcp"]\n' >>"$f"
    ok "đã thêm khối tino-connect vào $f"
  fi
  if have tino; then
    ok "chạy 'tino login' nếu chưa đăng nhập"
  else
    warn "chưa thấy lệnh 'tino' — Codex cần Tino CLI làm cầu nối; xem README của repo này"
  fi
}

install_zed() {
  say "== Zed"
  say "  Zed đọc khai báo máy chủ trong zed/server.json của repo này:"
  say "  máy chủ remote streamable-http tại $MCP_URL, tên tino-connect."
  say "  Thêm nó vào phần MCP/context servers trong cài đặt Zed của bạn, và"
  say "  chép zed/.agents/skills/ vào dự án nếu client của bạn đọc skill cục bộ."
}

show_manual() {
  say "== Cấu hình tay cho client MCP bất kỳ"
  say "  Khối JSON (Claude Code, Cursor, VS Code, Antigravity, ...):"
  say "    $MCP_JSON"
  say "  Codex (~/.codex/config.toml):"
  say '    [mcp_servers.tino-connect]'
  say '    command = "tino"'
  say '    args = ["mcp"]'
  say "  Chi tiết từng client: packages/tino-connect/SETUP.md"
}

run_target() {
  case "$1" in
    1|claude) install_claude ;;
    2|vscode|code) install_vscode ;;
    3|cursor) install_cursor ;;
    4|codex) install_codex ;;
    5|zed) install_zed ;;
    6|m|manual) show_manual ;;
    q|quit) exit 0 ;;
    *) warn "không hiểu lựa chọn: $1" ;;
  esac
}

detected() { have "$1" && printf '✔' || printf ' '; }

main() {
  if [ "$#" -gt 0 ]; then
    for target in "$@"; do run_target "$target"; done
    return
  fi
  say "Tino Connector — nối AI agent của bạn với tài khoản TINO qua Remote MCP."
  say ""
  say "  1) Claude Code        [$(detected claude)]"
  say "  2) VS Code            [$(detected code)]"
  say "  3) Cursor             [$(detected cursor)]"
  say "  4) Codex CLI          [$(detected codex)]"
  say "  5) Zed                [$(detected zed)]"
  say "  6) In cấu hình tay (client MCP bất kỳ)"
  say ""
  printf 'Chọn một hoặc nhiều (vd: "1 3", a = mọi client đã phát hiện, q = thoát): '
  local choice=""
  read -r choice </dev/tty || { warn "không đọc được lựa chọn"; exit 1; }
  if [ "$choice" = "a" ]; then
    choice=""
    have claude && choice="$choice claude"
    have code && choice="$choice vscode"
    have cursor && choice="$choice cursor"
    have codex && choice="$choice codex"
    have zed && choice="$choice zed"
    [ -n "$choice" ] || { warn "không phát hiện client nào trên PATH"; exit 1; }
  fi
  # shellcheck disable=SC2086
  for target in $choice; do run_target "$target"; done
}

main "$@"
