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

reject_text() {
  local text=$1
  if grep -Fq -- "$text" "$readme"; then
    printf 'README still contains untranslated copy: %s\n' "$text" >&2
    exit 1
  fi
}

require_text '## Có thể làm gì sau khi kết nối'
require_text '## Bắt đầu sử dụng Tino Connector'
require_text '## Cơ chế triển khai'
require_text '## Mua dịch vụ và thanh toán'
require_text '## An toàn, quyền hạn và giới hạn'
require_text '## Cài đặt bằng một lệnh'

require_text 'Tài khoản và thanh toán'
require_text 'Hosting, VPS và tên miền'
require_text 'Chẩn đoán website'
require_text 'Đề xuất môi trường triển khai'
require_text 'Mua dịch vụ và tên miền'
require_text 'Triển khai từ máy của bạn'
require_text 'DNS và đưa website vào hoạt động'

require_text 'Liệt kê toàn bộ hosting, VPS, tên miền và ngày gia hạn của tôi.'
require_text 'Triển khai dự án hiện tại lên VPS của tôi rồi trỏ staging.example.com.'
require_text 'AIM không bao giờ nhận mã nguồn hoặc SSH private key của bạn.'
require_text 'Bạn tự hoàn tất thanh toán trên trang thanh toán TINO được trả về.'
require_text 'Các thao tác khả dụng phụ thuộc vào phạm vi quyền bạn đã duyệt và các công cụ'
require_text 'thay đổi DNS đang hoạt động đều phải được'
require_text 'xác nhận rõ đối tượng và tác động.'
require_text 'DNS bên ngoài vẫn do bạn kiểm soát; trình kết nối chỉ trả hướng dẫn để bạn tự cấu hình.'

reject_text '## What you can do after connecting'
reject_text '## Start using Tino Connector'
reject_text '## How deployment works'
reject_text '## Purchasing and payment'
reject_text '## Safety, permissions, and limits'
reject_text '## One-command install'
reject_text 'Example prompts in English:'
reject_text '## Manual Remote MCP'
reject_text '## Other MCP clients'
reject_text '## What is inside'

printf 'readme_capability_contract_ok\n'
