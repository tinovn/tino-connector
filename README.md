# Tino Connector

Kết nối trợ lý AI hoặc IDE với tài khoản TINO qua Remote MCP và cơ chế đồng ý
OAuth. Trợ lý chỉ kết nối đến `https://aim.tino.vn/mcp`; bạn đăng nhập, duyệt
phạm vi quyền trong trình duyệt của mình và có thể thu hồi kết nối bất cứ lúc nào tại
cổng quản lý tài khoản TINO.

Kho mã nguồn công khai này chứa bộ cài, các gói trình kết nối và bảy kỹ năng
được phát hành cùng Tino Connector. Nội dung bạn thấy tại
[github.com/tinovn/tino-connector](https://github.com/tinovn/tino-connector)
chính là nội dung được bộ cài sử dụng. Gửi phản hồi đến support@tino.vn.

## Có thể làm gì sau khi kết nối

Tino Connector cung cấp cho trợ lý AI các kỹ năng hiểu hệ thống TINO và những
công cụ Remote MCP cần thiết để thực hiện công việc. Tino Connector không tạo
thêm màn hình quản trị riêng; hãy mở giao diện trợ lý hoặc trò chuyện bình thường trong
dự án rồi mô tả kết quả bạn muốn.

| Khả năng | Trợ lý có thể làm gì |
| --- | --- |
| **Tài khoản và thanh toán** | Đọc hồ sơ tài khoản, trạng thái xác minh số điện thoại, phạm vi quyền đã duyệt, tổng quan dịch vụ và hóa đơn đến hạn khi dữ liệu này khả dụng. |
| **Hosting, VPS và tên miền** | Liệt kê các dịch vụ bạn đang sở hữu, gồm trạng thái, sản phẩm, chu kỳ thanh toán, ngày gia hạn hoặc hết hạn và mức độ sẵn sàng để triển khai. |
| **Chẩn đoán website** | Kiểm tra DNS và HTTP từ máy của bạn, sau đó đối chiếu kết quả công khai với trạng thái tên miền, dịch vụ, đình chỉ và hóa đơn tại TINO. |
| **Đề xuất môi trường triển khai** | Phân tích dự án tại máy khách, ưu tiên dùng lại dịch vụ phù hợp đang có, chọn hosting cho website tĩnh/PHP/WordPress hoặc VPS cho Node.js, Python, container, tiến trình nền và yêu cầu quyền root. |
| **Mua dịch vụ và tên miền** | Duyệt danh mục TINO và chu kỳ thanh toán, kiểm tra tên miền còn trống cùng các trường đăng ký, trình giá để bạn duyệt, tạo đơn đã xác nhận, lấy hóa đơn và liên kết thanh toán, rồi kiểm tra kích hoạt sau thanh toán. |
| **Triển khai từ máy của bạn** | Xin quyền VPS hoặc cPanel có thời hạn, sau đó để trợ lý tại máy khách tự biên dịch và tải dự án trực tiếp lên đích. VPS Ubuntu 24.04 hoặc 26.04 mới có thể dùng bộ TINO LEMP bootstrap được bảo trì trước khi cấu hình ứng dụng. |
| **DNS và đưa website vào hoạt động** | Lập kế hoạch và áp dụng bản ghi được hỗ trợ cho tên miền gốc hoặc tên miền phụ bạn sở hữu, trỏ đến dịch vụ đã triển khai và kiểm tra lại DNS công khai. DNS bên ngoài vẫn do bạn kiểm soát; trình kết nối chỉ trả hướng dẫn để bạn tự cấu hình. |

Các kỹ năng đi kèm hướng dẫn trợ lý cách lựa chọn và phối hợp những quy trình này.
Công cụ MCP chỉ thực hiện các thao tác tài khoản mà kết nối hiện tại của bạn được
phép sử dụng.

## Bắt đầu sử dụng Tino Connector

Sau khi cài đặt và duyệt quyền trong trình duyệt, hãy bắt đầu một tác vụ bình
thường trong ứng dụng AI được hỗ trợ. Bạn chỉ cần yêu cầu bằng ngôn ngữ tự nhiên,
không cần nhớ cú pháp lệnh.

Ví dụ:

- `Kiểm tra trạng thái tài khoản TINO và số điện thoại đã xác minh chưa.`
- `Liệt kê toàn bộ hosting, VPS, tên miền và ngày gia hạn của tôi.`
- `Tôi còn hóa đơn nào chưa thanh toán?`
- `Chẩn đoán vì sao example.com không truy cập được.`
- `Dự án này nên triển khai lên hosting hay VPS? Ưu tiên dịch vụ tôi đang có.`
- `Tìm VPS 4 GB RAM và báo giá theo tháng, chưa đặt mua.`
- `Kiểm tra tino-example.io.vn còn trống không và báo phí một năm.`
- `Triển khai dự án hiện tại lên VPS của tôi rồi trỏ staging.example.com.`
- `Đây là WordPress. Hãy triển khai lên hosting đang có và sao lưu trước khi ghi đè.`
- `VPS này mới tinh. Chạy TINO LEMP bootstrap rồi triển khai Laravel và cấu hình Nginx/TLS.`
- `Cho tôi xem kế hoạch trỏ app.example.com về 203.0.113.10, chưa áp dụng.`

Với thao tác làm thay đổi dữ liệu hoặc hạ tầng, trợ lý phải hiển thị đúng đối
tượng và tác động rồi chờ bạn xác nhận. Bạn cũng có thể ghi rõ giới hạn như
`chỉ lập kế hoạch`, `chưa đặt mua` hoặc `không thay đổi DNS` ngay trong yêu cầu.

## Cơ chế triển khai

1. Trợ lý AI phía máy khách đọc dự án, xác định môi trường chạy, điểm khởi động,
   các bước biên dịch và lựa chọn đích phù hợp. Đây không phải nhiệm vụ của máy
   chủ AIM.
2. Trợ lý kiểm tra các dịch vụ TINO bạn đang có, trình kế hoạch triển khai rồi
   xin xác nhận trước khi cấp quyền truy cập hoặc thay đổi hạ tầng đang hoạt
   động.
3. Với VPS, trợ lý tạo cặp SSH key trên máy của bạn và chỉ gửi public key. AIM
   cài public key đó trong thời gian giới hạn rồi trả về host, port, username,
   thông tin host key để pin, fingerprint và `expires_at`. Với cPanel, AIM trả
   về hostname cùng UAPI token đã được duyệt và có thời hạn.
4. Trợ lý dùng thông tin kết nối đó ngay trên máy của bạn để đưa dự án lên đích
   bằng SSH, `rsync`, SFTP hoặc cPanel UAPI. VPS mới thuộc phiên bản được hỗ trợ có thể
   chạy tài nguyên chuẩn `tino://scripts/lemp-bootstrap-v2.sh` trước, sau đó mới
   nhận ứng dụng và cấu hình cơ sở dữ liệu, tiến trình, Nginx, TLS cần thiết.
5. Trợ lý kiểm tra ứng dụng và địa chỉ công khai, áp dụng kế hoạch DNS đã được
   duyệt khi bạn yêu cầu, sau đó báo kết quả hoặc khôi phục thay đổi lỗi nếu quy
   trình tương ứng hỗ trợ.

AIM không bao giờ nhận mã nguồn hoặc SSH private key của bạn. AIM chỉ là lớp
kết nối và cấp quyền; ứng dụng AI phía bạn trực tiếp đọc, biên dịch, tải lên,
kiểm tra và sửa mã nguồn từ máy của bạn.

## Mua dịch vụ và thanh toán

Kỹ năng mua dịch vụ tìm các thao tác danh mục, tên miền, đơn hàng, hóa đơn và
thanh toán đang được cấp quyền thay vì tự đoán tham số API. Quy trình thông
thường:

1. Duyệt sản phẩm, chu kỳ thanh toán, giá TLD hoặc kiểm tra tên miền còn trống.
2. Hiển thị sản phẩm đã chọn, giá, thông tin đăng ký và tác động dự kiến.
3. Chờ bạn xác nhận rõ ràng rồi tạo đúng một đơn hàng qua `cart.order`.
4. Lấy hóa đơn vừa tạo, các phương thức thanh toán và liên kết thanh toán.
5. Bạn tự hoàn tất thanh toán trên trang thanh toán TINO được trả về.
6. Trợ lý kiểm tra trạng thái hóa đơn và xác nhận dịch vụ hoặc tên miền mới đã
   xuất hiện trong danh sách tài sản của bạn.

Tino Connector không tự chuyển tiền thay bạn và không chuyển sang trình duyệt hoặc
luồng REST chưa được duyệt để né thao tác hay quyền đang thiếu.

## An toàn, quyền hạn và giới hạn

- Đăng nhập và duyệt phạm vi quyền (scope) diễn ra trên website TINO trong
  trình duyệt. Không dán mật khẩu TINO, OAuth token, SSH private key hoặc cPanel
  token vào cuộc trò chuyện.
- Các thao tác chỉ đọc có thể chạy trực tiếp. Việc cấp quyền triển khai, tạo đơn
  hàng, khởi tạo luồng thanh toán và thay đổi DNS đang hoạt động đều phải được
  xác nhận rõ đối tượng và tác động.
- VPS key và cPanel token chỉ có hiệu lực ngắn hạn. Trợ lý phải ngừng sử dụng
  khi đến `expires_at` và xóa thông tin xác thực tạm trên máy sau khi hoàn thành.
- Các thao tác khả dụng phụ thuộc vào phạm vi quyền bạn đã duyệt và các công cụ
  được cung cấp cho ứng dụng đang dùng. Kết nối lại không tự mở rộng quyền; hãy
  duyệt lượt cấp quyền mới khi thiếu phạm vi cần thiết.
- Chẩn đoán DNS dùng DNS công khai cùng dữ liệu tên miền và dịch vụ TINO đang
  khả dụng; trình kết nối không cam kết đọc được mọi bản ghi trong một vùng DNS.
- Chỉ có thể đổi nameserver khi kết nối hiện tại cung cấp đúng công cụ và quyền
  `domains:write`. Nếu không, trợ lý phải trình bày thay đổi để bạn tự thực hiện.
- Bạn có thể thu hồi kết nối bất cứ lúc nào tại cổng quản lý tài khoản TINO.

## Cài đặt bằng một lệnh

macOS hoặc Linux:

```bash
curl -fsSL https://aim.tino.vn/connect | bash
```

Windows PowerShell:

```powershell
irm https://aim.tino.vn/install.ps1 | iex
```

Trên Windows Command Prompt, bạn có thể tải và chạy
[`install.cmd`](https://github.com/tinovn/tino-connector/blob/main/install.cmd);
tệp này mở cùng menu PowerShell.

Hai URL bộ cài tại `aim.tino.vn` trả về đúng tập lệnh từ kho mã nguồn công khai
này, vì vậy mã nguồn hiển thị ở đây chính là mã nguồn được thực thi.

Menu hỗ trợ Claude Code, VS Code, Cursor, Codex, Zed, Hermes Agent và tùy chọn
cấu hình Remote MCP thủ công. Nếu tải tập lệnh trước, bạn có thể chọn ứng dụng mà
không mở menu, ví dụ `bash install.sh claude codex hermes` hoặc
`.\install.ps1 claude codex hermes`. Bộ cài gọi lệnh plugin chính thức của từng
ứng dụng hoặc thêm khai báo Remote MCP; bộ cài không cài `tino` CLI và không yêu
cầu mật khẩu hay token TINO. Đăng nhập OAuth và duyệt quyền diễn ra trong trình
duyệt.

## Claude Code

```
/plugin marketplace add tinovn/tino-connector
/plugin install tino-connect@tino
```

Sau đó chạy `/mcp`, chọn `tino-connect` và đăng nhập khi trình duyệt mở ra.
Lệnh CLI tương đương: `claude plugin marketplace add tinovn/tino-connector` và
`claude plugin install tino-connect@tino`.

## VS Code

Cài **Tino Connector** từ Visual Studio Marketplace
(`tinovn.aim-connector-vscode`), sau đó đăng nhập từ thanh trạng thái.

## Codex

```bash
codex plugin marketplace add tinovn/tino-connector
codex plugin add tino-connect@tino
```

Bắt đầu một tác vụ mới. Codex sẽ tải máy chủ Remote MCP cùng cả bảy kỹ năng từ
plugin, sau đó mở OAuth TINO khi cần truy cập lần đầu.

## Hermes Agent

```bash
hermes plugins install tinovn/tino-connector --enable
```

Khởi động lại Hermes Agent rồi xác thực kết nối đã lưu bằng
`hermes mcp login tino-connect`. Trình duyệt sẽ mở để đăng nhập TINO và duyệt
quyền; sau đó Hermes tải công cụ Remote MCP cùng bảy kỹ năng. Các bản cập nhật
tiếp theo thay đồng thời plugin và kỹ năng bằng
`hermes plugins update tino-connect`.

## Cấu hình Remote MCP thủ công

Mọi ứng dụng chấp nhận khai báo Remote MCP đều có thể dùng:

```json
{"mcpServers":{"tino-connect":{"type":"http","url":"https://aim.tino.vn/mcp"}}}
```

Khai báo này chỉ cho ứng dụng biết địa chỉ Tino Connector. Ứng dụng tự thực hiện
OAuth trong trình duyệt; không đặt thông tin xác thực TINO trong JSON.

## Các ứng dụng khách MCP khác

Xem [packages/tino-connect/SETUP.md](packages/tino-connect/SETUP.md) để lấy khối
cấu hình riêng cho Cursor, Antigravity và mọi ứng dụng chấp nhận khai báo Remote
MCP.

## Zed

Thư mục [zed/](zed/) chứa khai báo máy chủ và các kỹ năng trợ lý dành cho Zed.
Trong khi tiện ích chưa có trên kho Zed, hãy sao chép `zed/server.json` vào cấu
hình MCP của Zed và thư mục `zed/.agents/skills/` vào dự án.

## Thành phần trong kho mã nguồn

- Thư mục gốc — plugin Hermes Agent tích hợp gốc cùng bảy kỹ năng.
- `packages/tino-connect/` — plugin Claude Code và Codex: khai báo MCP, bảy
  kỹ năng (`account-status`, `list-services`, `diagnose-website`,
  `recommend-deployment`, `deploy-service`, `deploy-project`,
  `purchase-service`) và hướng dẫn cài đặt.
- `.agents/plugins/marketplace.json` — Marketplace tích hợp gốc cho Codex.
- `zed/` — tài nguyên cài đặt cho Zed.
- Giấy phép Apache-2.0. Hỗ trợ: support@tino.vn
