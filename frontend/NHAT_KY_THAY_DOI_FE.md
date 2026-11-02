# Nhật ký thay đổi FE – chuyển app phim sang chủ đề Travel (Phimium)

Ngày: 01/11/2026 · Phạm vi: thư mục `frontend/` (Flutter)

App FE trước đây là app xem **short drama** (CineShorts: phim, tập phim, xu, VIP, watchlist). Toàn bộ đã được chuyển sang **Phimium – food tour & history tour Sài Gòn cùng Buddy địa phương**, khớp với BE trong thư mục `BE/`.

> Bản gốc trước khi sửa được nén lại ở `../_backup_frontend_truoc_khi_doi.tar.gz` (file này đã bị `.gitignore` bỏ qua). Có thể khôi phục bằng git hoặc giải nén file này.

---

## 1. Đổi tên folder / feature

| Cũ (app phim) | Mới (travel) | Ghi chú |
|---|---|---|
| `features/drama/` | `features/tour/` | Tour, lịch trình, lịch khởi hành |
| `drama/.../drama_detail_page.dart` | `tour/.../tour_detail_page.dart` | Chi tiết tour |
| `drama/.../video_player_page.dart` | `tour/.../tour_itinerary_page.dart` | Xem lịch trình đầy đủ (thay màn xem video) |
| `features/bookmark/` | `features/wishlist/` | Tour yêu thích |
| `features/comment/` | `features/review/` | Đánh giá chuyến đi & Buddy |
| `features/payment/` | `features/booking/` | Đặt tour + thanh toán chuyển khoản |
| `features/search/` | `features/explore/` | Khám phá / tìm tour |
| `home/widgets/category_chips_bar.dart` | `tour_type_chips_bar.dart` | Lọc Tất cả / Food tour / History tour |
| `home/widgets/featured_hero_banner.dart` | `featured_tour_banner.dart` | Banner tour nổi bật |
| `home/widgets/continue_watching_section.dart` | `upcoming_trips_section.dart` | Chuyến đi sắp tới của tôi |
| `home/widgets/top_ranked_section.dart` | `departing_soon_section.dart` | Tour sắp khởi hành |
| `home/widgets/daily_coins_card.dart` | `buddy_match_card.dart` | CTA tìm Buddy |
| `home/widgets/horizontal_drama_row.dart` | `horizontal_tour_row.dart` | Hàng tour ngang |

Tên khác cũng được đổi: `AppShortDrama` → `PhimiumApp`, package `app_short_drama` → `phimium_mobile`, tên hiển thị Android/iOS/Web → **Phimium**.

**Tab dưới:** Home / Discover / Watchlist / Profile → **Trang chủ / Khám phá / Yêu thích / Tài khoản**.

**Route mới:** `/home`, `/explore`, `/wishlist`, `/profile`, `/tour/:id`, `/tour/:id/itinerary`, `/tour/:id/book`, `/bookings`, `/bookings/:id/review`, `/my-reviews`, `/buddy/:buddyId/reviews`, `/login`, `/register`, `/verify-otp`.

## 2. Đổi màu – "Saigon Jade & Saffron" (theme sáng)

Từ theme tối "Midnight Crimson & Gold" (nền đen, đỏ, vàng) sang theme sáng, ấm, hợp travel:

| Vai trò | Màu | Ý nghĩa |
|---|---|---|
| Primary | `#0E7C66` | Xanh ngọc – hàng cây, sông Sài Gòn |
| Secondary | `#E8833A` | Cam nghệ – đèn đường, ẩm thực |
| Tertiary | `#F6C453` | Vàng nắng (tag giá) |
| Background | `#FAF7F2` | Kem ấm |
| Surface/Card | `#FFFFFF` | Trắng |
| Text | `#1F2A2E` / `#5F6B70` | Chữ chính / phụ |
| Food tour | `#E8833A` | Nhãn Food tour |
| History tour | `#8B5E3C` | Nhãn History tour (nâu sepia) |

- Font đổi từ Plus Jakarta Sans sang **Be Vietnam Pro** (hiển thị tiếng Việt đẹp hơn).
- `AppTheme.darkTheme` → `AppTheme.lightTheme`; status bar icon màu tối.
- File liên quan: `core/theme/app_colors.dart`, `app_theme.dart`, `app_text_styles.dart`, `app_dimens.dart`.

## 3. Đã bỏ mock data

Toàn bộ dữ liệu giả đã bị xoá, thay bằng gọi API BE thật. Khi BE chưa có dữ liệu sẽ hiện màn "trống", khi lỗi sẽ hiện nút **Thử lại**.

| Chỗ có mock | Đã thay bằng |
|---|---|
| `home_page.dart`: list phim "Billionaire & CEO", "Werewolf" | `GET /api/activity/getAll` |
| `category_chips_bar.dart`: thể loại phim cứng | Lọc theo `activityType` (FOODTOUR / HISTORYTOUR) |
| Hero banner, Continue watching, Top 10, Daily coins | Tour thật / chuyến đi của tôi (`/api/activity/joined`) |
| `drama_detail_page.dart`: rating 4.8, 1.2M views | `GET /api/activity/{id}` (rating, Buddy, lịch trình) |
| `video_player_page.dart`: thời gian 03:24/12:00 | Lịch trình thật (itinerary stops) |
| `comment_page.dart`: "Bình luận (128)" | `GET /api/feedback/buddies/{buddyId}` |
| `payment_page.dart`: gói xu cứng | Đặt tour `POST /api/v1/registrations` + thanh toán `POST /api/payment/registration/{id}` |
| `profile_page.dart`: "3 Files (180 MB)", VIP chat | Thông tin user từ `/api/auth/me` |
| `login_page` / `register_page`: `Future.delayed` giả đăng nhập | AuthBloc thật gọi `/api/auth/login`, `/register`, `/verify-otp` |
| `bookmark_page`, `search_page`: list cứng | Yêu thích lưu trên máy + danh sách tour thật |

## 4. Kết nối BE (data layer)

- `ApiConstants` viết lại theo đúng controller của BE (`/api/auth`, `/api/activity`, `/api/v1/registrations`, `/api/payment`, `/api/feedback`).
- `unwrapData()` bóc `data` trong `ApiResponse { success, code, message, data }` của BE; lỗi hiển thị đúng `message` BE trả về.
- Refresh token: sửa đường dẫn `/api/auth/refresh` và đọc token trong `data`.
- `UserModel` viết tay theo `MeResponse` / `LoginResponse` (camelCase), **bỏ `user_model.g.dart`** nên không cần chạy build_runner. Bỏ `coinBalance`.
- Đăng ký theo đúng validate của BE: họ tên, email, SĐT VN 10 số, ngày sinh (≥16 tuổi), mật khẩu ≥8 ký tự có chữ + số + ký tự đặc biệt → sau đó nhập **OTP** (màn mới `verify_otp_page.dart`).
- DI (`core/di/injection.dart`) đã đăng ký đầy đủ: DioClient, Auth, Tour, Booking, Review, Wishlist. `AuthBloc` được cấp ở gốc app.
- Chi tiết tour: BE `ActivityDetailResponse` không có `departures` nên FE ghép lịch khởi hành từ `getAll`.

## 5. File mới

`core/utils/formatters.dart` (tiền VND, ngày, giờ, thời lượng) · `shared/widgets/state_widgets.dart` thêm `AsyncView` · `tour/` (entity, model, datasource, repository, `tour_card.dart`, `itinerary_timeline.dart`) · `booking/` (`booking_page`, `my_bookings_page`, `payment_sheet`) · `review/` (`review_page`, `write_review_page`, `my_reviews_page`) · `wishlist/` · `explore/` · `auth/.../verify_otp_page.dart` · `.env.example` · `assets/{images,icons,animations}/.gitkeep` · test mới trong `test/widget_test.dart`.

## 6. pubspec.yaml

- `name: phimium_mobile`, mô tả mới.
- Bỏ `video_player`, `chewie`, `in_app_purchase` (chỉ dùng cho xem phim / mua xu, không còn code nào dùng).

## 7. Việc bạn cần làm khi chạy

1. **Tạo file `.env`**: copy `.env.example` → `.env` (công cụ không được phép ghi file `.env` nên mình chỉ tạo file mẫu). Thiếu `.env` thì `flutter build` sẽ báo lỗi asset.
2. `flutter pub get` (pubspec đổi tên + bỏ package → `pubspec.lock` sẽ tự cập nhật).
3. `flutter analyze` và `flutter test` – môi trường của mình không có Flutter SDK nên **chưa compile thử được**; mình đã kiểm tra import và tên hằng số bằng script, nếu analyze báo lỗi nhỏ thì gửi mình sửa.
4. Chạy BE ở cổng 8080. Android emulator dùng `http://10.0.2.2:8080`, máy thật dùng IP LAN.

## 8. Chưa làm / lưu ý

- `applicationId` / `namespace` Android vẫn là `com.shortdrama.app_short_drama` (đổi cần chuyển cả thư mục Kotlin, dễ lỗi build) – chỉ đổi tên hiển thị.
- BE chưa có API wishlist → tour yêu thích đang lưu trên máy (`shared_preferences`).
- Thanh toán: FE gọi tạo payment rồi mở `checkoutUrl` của SePay; nếu SePay cần POST form với `fields` thì nên làm thêm WebView.
- Chưa làm: quên mật khẩu, đăng nhập Google, AI matching Buddy (BE đã có `/api/ai/matches`), màn Buddy (lịch dẫn tour, check-in).
