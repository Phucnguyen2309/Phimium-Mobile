# Registration → SePay

## Luồng mới

1. Đăng nhập bằng ACCESS JWT.
2. POST /api/v1/pricing/quote: xem giá theo departureId, adultCount, childCount, couponCode.
3. POST /api/v1/registrations: backend kiểm tra lại dữ liệu, tính lại giá từ database, giữ chỗ/coupon và lưu pickupLocation.
4. Đơn có tổng tiền > 0 trả PENDING_PAYMENT + paymentExpiresAt. Chưa ghép nhóm/Buddy.
5. POST /api/payment/registration/{registrationId}: trả checkoutUrl + fields. Gọi lặp khi còn hạn trả lại payment/invoice pending, không tạo thêm giao dịch.
6. Frontend dựng form POST với fields (giữ thứ tự) và submit đến checkoutUrl để mở SePay.
7. SePay POST IPN đến /api/webhooks/sepay, header X-Secret-Key phải khớp SEPAY_IPN_SECRET.
8. ORDER_PAID hợp lệ: đối chiếu invoice, số tiền/tiền tệ ở cả order và transaction, trạng thái CAPTURED/APPROVED và loại PAYMENT. Payment trở thành PAID; registration được đánh dấu paymentConfirmedAt, ghép nhóm theo ca và tổng khách, chuyển WAITING_FOR_BUDDY hoặc BUDDY_ASSIGNED.
9. Frontend gọi GET /api/payment/{paymentId} hoặc GET /api/v1/registrations/me để đọc trạng thái. Không tự xác nhận đã trả tiền từ URL success.
10. Hết hạn chưa thanh toán: job mỗi 30 giây hủy đơn, trả chỗ/coupon đúng một lần và đổi payment pending thành EXPIRED.
11. Booking xác nhận thành công: lưu mail chờ gửi trong cùng transaction; job gửi email thông tin chuyến đi và các Buddy tới người đặt. SMTP lỗi sẽ tự thử lại. Chi tiết: [BOOKING-EMAILS.md](BOOKING-EMAILS.md).

Không thêm giỏ hàng, gói tastings, phụ phí dịch vụ hay form thông tin liên hệ. Khách sạn/địa chỉ đón lưu tại pickupLocation.

## Quy tắc

- BOOKING_HOLD_MINUTES: mặc định 15 phút, không vượt giờ khởi hành.
- Adult >= 1, child >= 0; tối đa 1000 mỗi trường để tránh tràn số; tổng khách không vượt capacity và groupMaxSize (mặc định 6). Hiện mô hình một registration/một nhóm/một Buddy nên chưa tách một đơn lớn ra nhiều nhóm.
- Không đặt ca quá giờ, đóng/hủy hoặc activity đã hủy/kết thúc.
- Giá chốt từ backend; VND, làm tròn tổng và giảm giá đến đồng theo HALF_UP. Không tự quy đổi USD.
- Coupon được giữ lượt khi tạo đơn; trả lại khi hủy/hết hạn. Lock coupon ngăn nhiều ca đồng thời vượt usageLimit.
- Tổng tiền 0: xác nhận booking trực tiếp và ghép Buddy, không gửi giao dịch PURCHASE 0 đồng; vẫn có thể hủy trước khởi hành để trả chỗ/coupon.
- Một user không tạo hai registration chưa hủy cho cùng ca: lần gọi trùng trả conflict; dùng /registrations/me để lấy lại đơn đã tạo.
- Payment và registration được lock khi thay đổi, receipt lặp cùng transaction không xử lý lại.
- Check-in cần paymentConfirmedAt và BUDDY_ASSIGNED, giữ điều kiện khung giờ cũ.
- Tiền về sau khi hết hạn/hủy, ca bị hủy, hoặc thông báo TRANSACTION_VOID: payment REVIEW_REQUIRED. Không tự hồi sinh booking đã trả chỗ. VOID của đơn đã xác nhận chuyển registration PAYMENT_REVIEW và chặn check-in.
- Hủy đơn đã thanh toán trả lỗi yêu cầu review; chưa có tích hợp hoàn tiền tự động. REVIEW_REQUIRED phải được đối soát với SePay bởi người quản trị. Không tự ghi PAID thành FAILED vì khách quay về error/cancel URL.
- Không khóa phiên thanh toán bên SePay khi hết hạn local; IPN tiền về muộn được giữ để đối soát.
- Tích hợp hiện hỗ trợ BANK_TRANSFER như cấu hình cũ. Không gọi dịch vụ thật trong test.

Import collection docs/registration-sepay.postman_collection.json để thử các bước theo thứ tự.
Đặt departureId; collection tự lưu registrationId/paymentId/invoiceNumber. Collection cũ
có header Bearer {{accessToken}}: nếu dùng cookie đăng nhập của Postman, tắt header
Authorization đó để không ghi đè cookie bằng token rỗng. Không export token/credential vào Git.

## Ví dụ API

Các API ngoài webhook yêu cầu đăng nhập. AuthController hiện ghi token vào cookie
HttpOnly và bỏ token khỏi JSON. Dùng cookie jar từ response login; BE cũng nhận
Authorization: Bearer <accessToken> khi client có access token hợp lệ.

POST /api/v1/pricing/quote:
```json
{"departureId":"<UUID>","adultCount":2,"childCount":1}
```

POST /api/v1/registrations:
```json
{
  "departureId": "<UUID>",
  "adultCount": 2,
  "childCount": 1,
  "pickupLocation": "Khách sạn ABC, 123 Nguyễn Huệ, Quận 1",
  "isSafetyTermsAccepted": true
}
```

couponCode tùy chọn; pickupLocation bắt buộc, trim, tối đa 500 ký tự.
Response bọc ApiResponse, data.registrationId/data.status/data.paymentExpiresAt.

POST /api/payment/registration/<registrationId>:
```json
{"paymentMethod":"BANK_TRANSFER"}
```

Dùng data.checkoutUrl làm action form POST; data.fields thành hidden inputs. Không đưa secret key ra frontend; backend đã ký signature.

POST /api/v1/registrations/<registrationId>/cancel: hủy đơn chưa thanh toán.
GET /api/payment/<paymentId>: chỉ chủ đơn được xem payment.
GET /api/v1/registrations/me: xem booking, pickupLocation, deadline và thời điểm xác nhận tiền.

## Cấu hình SePay

Đã chuyển sepay trong application.yaml ra cấp gốc để khớp SePayProperties.

Giữ các biến hiện có:
SEPAY_MERCHANT_ID, SEPAY_SECRET_KEY, SEPAY_CHECKOUT_URL, SEPAY_API_URL,
SEPAY_SUCCESS_URL, SEPAY_ERROR_URL, SEPAY_CANCEL_URL.

Thêm:
- SEPAY_IPN_SECRET: secret dành cho IPN, đặt cùng giá trị tại SePay merchant với auth type SECRET_KEY. Không tự dùng chung signing secret.
- BOOKING_HOLD_MINUTES: tùy chọn, mặc định 15.

Nếu thiếu cấu hình bắt buộc, create payment/webhook trả lỗi rõ ràng, không chấp nhận IPN không xác thực.
Cần đưa biến vào environment JVM/IDE; app vẫn chưa tự nạp .env.

Cấu hình IPN merchant là URL HTTPS công khai /api/webhooks/sepay. Localhost cần tunnel.

### Chạy Sandbox với một application.yaml

Dự án dùng một `application.yaml` và các biến `SEPAY_*` hiện có trong `.env`.
Không cần `application-sandbox.yaml`, Active profiles hoặc các biến
`SEPAY_SANDBOX_*`. Nếu IDE trước đó đặt Active profiles là `sandbox`, bỏ giá trị đó.

```dotenv
SEPAY_MERCHANT_ID=<merchant Sandbox của bạn>
SEPAY_SECRET_KEY=<signing secret Sandbox của bạn>
SEPAY_IPN_SECRET=<secret tự đặt, giống cấu hình IPN trên SePay>
SEPAY_CHECKOUT_URL=https://pay-sandbox.sepay.vn/v1/checkout/init
SEPAY_API_URL=https://pgapi-sandbox.sepay.vn
```

Hai URL trên cũng là mặc định trong `application.yaml`. Không commit credential.
Merchant Sandbox thường có tiền tố `SP-TEST-`, signing key có tiền tố `spsk_test_`;
xác nhận môi trường trên dashboard trước khi dùng. IPN secret là giá trị riêng,
không dùng chung signing secret. Chọn Test Mode, Auth Type Secret Key, Content Type
application/json và bật IPN trong trang cấu hình SePay.

`SEPAY_SUCCESS_URL`, `SEPAY_ERROR_URL`, `SEPAY_CANCEL_URL` giữ tên hiện có.
BE phục vụ ba trang GET công khai `/payment/success`, `/payment/error`, `/payment/cancel`;
mặc định local là `http://localhost:8080/payment/...` (không dùng cổng 5173).
Khi chạy thiết bị thật/browser ngoài máy BE, đặt các URL này theo HTTPS tunnel/domain BE.
Trang chỉ hiển thị PAID sau khi GET API payment đã xác thực trả PAID; URL success không chứng minh thanh toán.
Flutter Android/iOS dùng WebView gửi nguyên `fields` qua form POST, chặn return URL đúng paymentId
để quay lại sheet, rồi đọc API owner-only và chờ IPN tối đa 10 giây; có nút kiểm tra lại.
Thiếu credential bắt buộc thì tạo payment trả `SEPAY_NOT_CONFIGURED`.

File `.env` không tự được Spring Boot nạp. Chọn file trong Run Configuration
của IDE hoặc truyền environment khi tạo container. Docker image/container đang
chạy không tự nhận source hoặc `.env` mới; cần build image và tạo lại container
khi source thay đổi. Chỉ đổi `.env` thì tạo lại container với image hiện có,
không cần build lại. Không in `docker inspect` toàn bộ vì
có thể làm lộ credential.

Tham khảo: [Sandbox chính thức](https://developer.sepay.vn/vi/cong-thanh-toan/sandbox).

Tài liệu chính thức:
- https://developer.sepay.vn/vi/cong-thanh-toan/IPN
- https://developer.sepay.vn/vi/cong-thanh-toan/API/don-hang/form-thanh-toan

Ví dụ IPN sandbox (chỉ gửi bằng test khi biết secret; production do SePay gửi):
```json
{
  "notification_type": "ORDER_PAID",
  "order": {
    "order_invoice_number": "<invoiceNumber>",
    "order_id": "<SePay order id>",
    "order_status": "CAPTURED",
    "order_currency": "VND",
    "order_amount": "250000"
  },
  "transaction": {
    "transaction_id": "<unique transaction id>",
    "transaction_type": "PAYMENT",
    "transaction_status": "APPROVED",
    "transaction_currency": "VND",
    "transaction_amount": "250000"
  }
}
```

## Database

Hướng dẫn migration legacy bên dưới chỉ có ý nghĩa khi có script migration
tương ứng từ nhóm. Checkout hiện tại không có `database/registration-payment-flow.sql`;
không chạy một đường dẫn không tồn tại hoặc áp dụng lại migration legacy trên DB đang dùng.

Script bổ sung pickup_location/payment_expires_at/payment_confirmed_at, cập nhật status checks,
unique provider_transaction_id và chuyển trạng thái legacy.
- PAID thực tế được backfill confirmation; legacy CONFIRMED không tự coi là đã trả tiền.
- Đơn cũ chưa trả được chuyển PENDING_PAYMENT, bỏ group/Buddy sớm, giữ số chỗ/coupon đã trừ và thêm deadline.
- Pending payments trùng giữ một bản; receipt cũ vẫn nhận để review.
- Dừng nếu có provider transaction trùng hoặc nhiều PAID trong cùng booking; cần đối soát thủ công.
- Kiểm tra constraint tùy chỉnh trước khi chạy: script thay status CHECK hiện có.
- Legacy IN_PROGRESS/COMPLETED chưa có payment evidence cần kiểm tra riêng; không tự tạo xác nhận thanh toán.
- Các giá legacy có phần lẻ VND cần kiểm tra trước khi tiếp tục checkout; đơn mới chốt nguyên VND.

## Kiểm tra

Theo yêu cầu ngày 2026-11-03, các file test Payment do agent thêm đã được xóa;
không có suite Payment được duy trì trong source hiện tại. Kết quả 71 test trong
worklog là bằng chứng lịch sử trước khi xóa, không phải bộ test đang chạy.
Từ giai đoạn 3 kiểm tra bằng build, API local và thao tác thực tế; không tạo file test mới.

Build BE với JDK 17/21 từ thư mục BE:

```bash
bash mvnw -B -Dmaven.test.skip=true package
```

Build FE từ thư mục frontend:

```bash
flutter analyze lib/features/payment lib/features/booking/presentation/pages/payment_checkout_page.dart lib/features/booking/presentation/widgets/checkout_form.dart lib/features/booking/presentation/widgets/payment_sheet.dart
flutter build apk --debug
```

Build không chứng minh IPN thật, locking PostgreSQL hoặc giao diện trên thiết bị.
Kết quả từng lần kiểm tra và giới hạn ghi trong docs/WORKLOG.md của dự án.

## Payment giai đoạn 2 — lịch sử, retry và đối soát

Trên app: Tài khoản → Lịch sử thanh toán → chọn giao dịch. Có phân trang,
kiểm tra trạng thái và thông báo rõ khi vẫn PENDING/lỗi mạng. Đóng app không mất
khả năng xem giao dịch vì danh sách/chi tiết đọc lại từ API đã xác thực.
Sheet checkout hỗ trợ cuộn, chặn bấm lặp, kiểm tra trạng thái trước khi mở lại;
create-payment vẫn do BE kiểm tra hạn/ownership và dùng lại invoice đang pending.

API thêm: `POST /api/payment/{paymentId}/reconcile`, chỉ chủ payment được gọi.
Không nhận amount/status/receipt do client cung cấp. BE gọi trực tiếp API chi tiết SePay
bằng invoice; chỉ receipt đầy đủ, đúng invoice,
customer và một PAYMENT APPROVED mới được chuyển vào cùng bộ xử lý IPN có lock.
Số tiền/tiền tệ được đối chiếu lại với DB. Đơn đã hủy/hết hạn không tự hồi sinh:
receipt hợp lệ được đưa REVIEW_REQUIRED theo quy tắc có sẵn.
PAID/REVIEW_REQUIRED trả trạng thái hiện tại, không gọi lại provider.
Có giới hạn 30 giây/payment trong một instance; không tự retry HTTP provider.

REST detail dùng UUID `transactions[].id`, lưu riêng ở `payment.provider_receipt_id`
(UUID nullable, unique). IPN nhận thêm cùng UUID `transaction.id`; mã ngắn
`transaction_id` vẫn lưu ở `provider_transaction_id`, không trộn hai loại ID.
REST trước/IPN sau hoặc ngược lại phải khớp ít nhất một ID đã lưu, không được
mâu thuẫn ID còn lại; chỉ bổ sung ID còn thiếu, không confirm/release lần hai.
IPN public vẫn yêu cầu transaction_id như contract cũ. REST chỉ được gọi bộ xử lý
nội bộ sau Basic Auth và kiểm tra order/customer/receipt. Provider timeout/403,
thiếu cả hai ID, UUID sai định dạng hoặc dữ liệu không rõ trả 503/code 9013.
Code 9014/429 yêu cầu đợi trước lần đối soát tiếp. Không đổi User-Agent/proxy.
Local đang dùng Hibernate ddl-auto=update: restart BE để thêm cột nullable/unique;
không sửa/xóa receipt cũ. Schema local đã được kiểm tra ngày 2026-11-03:
`provider_receipt_id` UUID, `last_auto_reconciled_at` timestamp và unique index
cho invoice/UUID receipt/mã giao dịch ngắn đều tồn tại. Đây là kết quả DB local,
không thay thế việc kiểm tra DB của người nhận.
- [API danh sách đơn](https://developer.sepay.vn/en/cong-thanh-toan/API/don-hang/danh-sach-don-hang)
- [API chi tiết đơn](https://developer.sepay.vn/en/cong-thanh-toan/API/don-hang/chi-tiet-don-hang)
- [IPN và transaction_id](https://developer.sepay.vn/vi/cong-thanh-toan/IPN)

Log IPN chỉ ghi invoice đúng định dạng, mã lỗi, HTTP status và thời gian xử lý;
không ghi headers, secret hoặc nguyên payload. Nếu tunnel không tới BE sẽ không
có log request tương ứng; dùng nhật ký IPN SePay để xem lỗi kết nối.

Nghiệm thu 2026-11-03: 56 test BE, 13 test Flutter đạt; APK debug build thành công.
History/detail được xem trên Android emulator với dữ liệu tài khoản test thật;
endpoint đối soát owner trên payment đã PAID giữ nguyên receipt và anonymous 401.
Các ca provider 403/thiếu receipt, duplicate/late/VOID và UI pending/error được
kiểm tra bằng test cô lập. Chưa gọi provider thật để phục hồi hai đơn cũ bị lỡ IPN;
chưa coi chúng đã được đối soát. SePay IPN qua tunnel mới và checkout tự mở đã có
bằng chứng user cung cấp trước giai đoạn này, không phải test mới của phase 2.

### Tra cứu trực tiếp mã hóa đơn (giai đoạn 3)

BE gọi đúng một endpoint `/v1/order/detail/{order_invoice_number}` cho mỗi lượt
đối soát, xác thực Basic Auth bằng cấu hình server. Không quét danh sách merchant,
không phụ thuộc bộ lọc q/customer_id hoặc số trang danh sách. Chủ đơn và invoice
trong response vẫn phải khớp dữ liệu local, order_id không rỗng; chỉ một giao dịch
PAYMENT APPROVED của order CAPTURED được xử lý, số tiền/tiền tệ đối chiếu DB.
404 nghĩa là chưa thấy đơn tại provider, không ghi nhận đã trả tiền. HTTP403/429,
5xx, lỗi kết nối/JSON hoặc receipt không rõ đều từ chối an toàn 9013, không tự retry
HTTP và không đổi trạng thái local. Timeout kết nối 4 giây, đọc 6 giây như cũ.
Contract: https://developer.sepay.vn/vi/cong-thanh-toan/API/don-hang/chi-tiet-don-hang

### Đối soát tự động khi mất IPN

BE bật đối soát tự động mặc định cho payment provider SEPAY còn PENDING, được tạo
ít nhất 15 giây trước. Mỗi lượt tối đa 5 đơn; lượt sau chạy 30 giây sau khi lượt
trước kết thúc trên thread riêng `payment-reconcile-`, không chặn scheduler booking.
Đơn PAID/REVIEW_REQUIRED/EXPIRED/FAILED không nằm trong lượt quét tự động; đơn hết
hạn cần đối soát thủ công để ghi nhận tiền về muộn theo quy tắc REVIEW_REQUIRED.

`payment.last_auto_reconciled_at` lưu lần claim gần nhất, độc lập update_at.
Query ưu tiên đơn lâu chưa kiểm tra, sau đó ID; claim bằng UPDATE có điều kiện
trước HTTP và commit ngay. Các BE dùng chung DB không cùng claim một đơn trong
cùng khoảng kiểm tra. Không giữ transaction DB trong lúc chờ SePay. Receipt vẫn
được xử lý qua processor có lock/kiểm tra số tiền/tiền tệ/UUID và idempotency.
Lỗi provider 9013 dừng lượt, giữ trạng thái; lượt sau thử lại. Lỗi cooldown 9014
của một đơn không chặn các đơn còn lại. Giới hạn 5 đơn là mỗi instance/lượt,
không phải rate limit toàn merchant; không cam kết SLA khi backlog/provider lỗi.

Các biến tùy chọn (không cần thêm vào .env để dùng mặc định):
- SEPAY_AUTO_RECONCILIATION_ENABLED=true; đổi false và restart để tắt tác vụ.
- SEPAY_AUTO_RECONCILIATION_INTERVAL_MS=30000 (30000–3600000).
- SEPAY_AUTO_RECONCILIATION_BATCH_SIZE=5 (1–5).

Restart BE với ddl-auto=update hiện có để thêm cột nullable; không xóa dữ liệu cũ.
FE sheet và trang chi tiết đọc trạng thái BE mỗi 5 giây khi PENDING, foreground
và đúng route đang hiển thị; hủy timer khi dispose, không tự gọi reconcile từ FE.
Nút đối soát thủ công và IPN vẫn hoạt động. Log `Payment auto reconciliation`
ghi paymentId/status hoặc mã lỗi, không ghi credential/payload.

Nghiệm thu thủ công: tắt tunnel, tạo đơn còn hạn, giả lập trả tiền, quay lại sheet
hoặc chi tiết và chờ lượt quét (thường 15–40 giây sau khi giả lập thanh toán với ít đơn; phụ thuộc thời điểm lượt quét và độ trễ SePay). Không bấm đối soát.
Kỳ vọng log auto status=PAID và UI tự đổi; chưa trả tiền phải giữ PENDING.

### Demo và bàn giao Payment Sandbox — giai đoạn 3

1. Mỗi người dùng merchant/key Sandbox riêng, khai báo trong BE/.env được Git ignore;
   không gửi key trong ảnh, commit hoặc worklog. Không cần application-sandbox.yaml.
2. Chạy PostgreSQL, cấu hình BE và khởi động một instance trên 8080. FE Android
   emulator dùng địa chỉ 10.0.2.2:8080. Docker local cũng cần DB/env đúng cấu hình.
3. Demo IPN: mở cloudflared tới 8080, lưu URL hiện tại + /api/webhooks/sepay tại
   SePay Sandbox; bật xác thực Secret Key khớp SEPAY_IPN_SECRET. Tunnel khởi động lại
   có thể đổi hostname, phải cập nhật IPN. IPN HTTPS public là đường thông báo chính.
4. Demo phục hồi: tắt tunnel, tạo đơn mới còn hạn, giả lập trả tiền, trở lại Payment
   và không bấm nút. BE tự đối soát và FE tự đọc trạng thái; thông thường 15–40 giây
   khi ít đơn. Backlog/lỗi provider có thể lâu hơn. Không chuyển tiền lần nữa.
5. Đơn chưa trả tiền giữ PENDING, hết hạn theo booking hiện có; không suy ra PAID từ
   trang success hoặc đóng WebView. Tiền được xác minh sau hết hạn/hủy giữ REVIEW_REQUIRED.
6. Lịch sử → chi tiết: UUID providerReceiptId hiển thị riêng “Mã biên nhận SePay”;
   mã ngắn providerTransactionId chỉ xuất hiện khi có, không dùng UUID thay thế mã ngắn.
   Lỗi mở WebView có nút quay lại kiểm tra, không tự submit lại hoặc tạo invoice khác.
7. Nghiệm thu quyền với hai account độc lập: B không GET/reconcile payment của A;
   USER không vào /api/v1/admin/payments; anonymous bị 401; IPN sai secret bị từ chối.
8. Nghiệm thu lỗi mạng: ngắt kết nối khi PENDING, không được tự thành PAID;
   khôi phục mạng, chờ lượt đối soát tiếp. Nhận IPN/đối soát lặp phải giữ cùng receipt
   và không cấp chỗ/confirm lần hai. Không tự ghi PAID trong DB để làm demo.

Recovery: SEPAY_AUTO_RECONCILIATION_ENABLED=false và restart chỉ tắt job tự động;
IPN và nút đối soát thủ công vẫn dùng được. Không tắt xác thực/TLS để khắc phục lỗi.
Hoàn tiền tự động, chuyển production và nghiệp vụ xử lý thủ công REVIEW_REQUIRED
không thuộc giai đoạn này; không giả định đã có dashboard giải quyết các trạng thái đó.

### Bàn giao và chạy Docker — giai đoạn 4

Dùng `BE/Dockerfile` có sẵn. Không cần thêm application profile, Compose hoặc
file env mẫu. Người nhận tự đặt `.env` được chia sẻ riêng vào thư mục `BE`;
Git vẫn bỏ qua file này. Giữ dạng `KEY=value`, không dùng `export` hoặc bọc giá trị
bằng dấu nháy khi truyền qua `docker run --env-file` (dấu nháy sẽ thành một phần giá trị).
Không dùng `source .env`: tên biến Cloudinary dạng dấu chấm không hợp cú pháp shell.

Điều kiện trước khi chạy:

- Docker Desktop đang chạy; PostgreSQL đã có database và dữ liệu tour/ca còn hạn.
- DB_USER/DB_PASSWORD/DB_PORT/DB_NAME đúng trên máy người nhận. `.env` không chứa dữ liệu DB;
  dùng bản sao DB development/seed được nhóm cung cấp nếu máy mới chưa có dữ liệu.
- Merchant/key thuộc Sandbox; người nhận cần dùng cùng merchant với invoice cần đối soát.
  Đơn tạo bằng merchant cũ không tự chuyển sang merchant mới.
- SEPAY_IPN_SECRET khớp Secret Key trên dashboard; ba return URL dùng cổng 8080,
  không dùng localhost:5173. Các cấu hình ứng dụng ngoài Payment giữ như thiết lập của nhóm.

Từ thư mục gốc dự án, build source hiện tại:

```bash
docker build -t phimium-be:payment-sandbox ./BE
```

Sau khi tự dừng BE IntelliJ nếu đang giữ cổng 8080, chạy BE trên Docker (Mac):

```bash
docker run -d --name phimium-payment-sandbox \
  --env-file ./BE/.env \
  -e DB_HOST=host.docker.internal -e PORT=8080 \
  -p 127.0.0.1:8080:8080 \
  phimium-be:payment-sandbox
```

`localhost` bên trong container là chính container, nên phải ghi đè DB_HOST như trên.
PostgreSQL trên Mac cần cho phép kết nối từ Docker bằng tài khoản/mật khẩu đúng;
không đổi pg_hba sang trust để khắc phục lỗi. Lệnh trên không tạo PostgreSQL mới,
không mount/xóa dữ liệu DB. Không chạy hai BE trỏ cùng DB chỉ để thử vì cả hai có job nền.
Linux Docker Engine có thể cần thêm `--add-host=host.docker.internal:host-gateway`.

Mở `http://localhost:8080/swagger-ui/index.html`, sau đó chạy FE:

```bash
cd frontend
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

IPN realtime trên BE Docker local cũng cần tunnel:

```bash
cloudflared tunnel --url http://localhost:8080
```

Lưu **hostname mới + `/api/webhooks/sepay`** vào SePay Test Mode; Auth Type Secret Key,
Content Type application/json, bật IPN. Giữ terminal tunnel mở. Tắt tunnel vẫn có thể
checkout và phục hồi bằng REST tự động nếu BE/DB/Internet hoạt động; IPN không đến realtime.
Không chia sẻ hostname của phiên tunnel cũ như một địa chỉ cố định.

Checklist nghiệm thu trên máy người nhận:

1. Đăng nhập account development đã có; lịch sử chỉ hiện payment của account đó.
2. IPN bật: tạo đơn còn hạn, giả lập thanh toán; nhật ký IPN mới phải HTTP 200 và
   API/UI thành PAID. Root URL, 401 hoặc 530 không phải nghiệm thu IPN thành công.
3. Tắt tunnel: tạo đơn khác còn hạn, giả lập, không bấm đối soát; chờ job BE và FE
   tự hiển thị PAID. Đơn chưa giả lập vẫn PENDING. Không thanh toán lại khi đang chờ.
4. Ghi lại invoice, receipt, paidAt; chạy `docker restart phimium-payment-sandbox`,
   đăng nhập lại nếu cần và mở lịch sử: trạng thái/receipt/paidAt phải còn nguyên.
5. Kiểm tra lặp không tạo receipt mới; tiền về muộn sau hủy/hết hạn phải REVIEW_REQUIRED.
   Không tự đặt PAID bằng SQL để làm bằng chứng.

Xem log tại máy, chỉ chia sẻ dòng Payment đã che thông tin nhạy cảm. Spring có thể
in generated security password trong log khởi động; không gửi toàn log/container inspect.
SMTP lỗi không đồng nghĩa Payment thất bại; kiểm tra status/receipt qua API Payment.

Thay source: build image lại, rồi dừng/xóa **đúng container BE này** và chạy lại lệnh run.
Chỉ thay env: dừng/xóa container này rồi run lại, không cần build. `docker restart`
giữ env lúc tạo container, không đọc lại file. Các lệnh thao tác container BE:

```bash
docker stop phimium-payment-sandbox
docker rm phimium-payment-sandbox
```

Không dùng xóa volume hoặc dọn Docker hàng loạt. Dữ liệu nằm ở PostgreSQL riêng.
Rollback code cần image cũ còn giữ; không tự rollback schema hay receipt đã ghi.
Nếu cần tắt auto job, đặt SEPAY_AUTO_RECONCILIATION_ENABLED=false rồi tạo lại container;
IPN và đối soát thủ công vẫn hoạt động.

Trước khi push, tự xem `git status --short`: không đưa BE/.env, cookie, dump DB hay
log có key vào commit. Phần commit/push do người dùng thực hiện.

Kiểm chứng đóng gói ngày 2026-11-03: image `phimium-be:payment-sandbox` build bằng
Dockerfile có sẵn thành công. Khởi động với PostgreSQL 16 tạm tách khỏi DB người dùng:
11 kiểm tra API/schema/job/restart đạt, bao gồm truy vấn chọn đơn tự động và unique
UUID receipt. Container/network/env tạm đã dọn. Không tạo file test được duy trì.
DB local hiện tại chỉ được đọc metadata cột/index, không sửa dữ liệu.
Chưa tạo giao dịch SePay đầu-cuối trên image Docker hoặc chạy trên máy người nhận;
chưa dùng kết quả restart schema để khẳng định đã kiểm tra giữ receipt của đơn PAID.
Các bằng chứng SePay/IPN thực ở giai đoạn 3 thuộc bản BE chạy qua IntelliJ.
