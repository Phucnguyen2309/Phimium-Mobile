# Phimium Mobile (Flutter)

App đặt food tour & history tour Sài Gòn cùng Buddy địa phương.

## Chạy app

1. Khởi động BE (thư mục `../BE`) trên cổng 8080.
2. `flutter pub get`
3. Android emulator: `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080`

Android emulator dùng `http://10.0.2.2:8080`, iOS simulator / web dùng `http://localhost:8080`.

Không cần tạo `.env` FE. File `.env` hiện không được khai báo trong assets;
`--dart-define` có ưu tiên cao hơn cấu hình mặc định. Khi đổi địa chỉ, chạy lại app.
Hướng dẫn Docker và nghiệm thu Payment Sandbox: [REGISTRATION-SEPAY.md](../BE/docs/REGISTRATION-SEPAY.md#bàn-giao-và-chạy-docker--giai-đoạn-4).
