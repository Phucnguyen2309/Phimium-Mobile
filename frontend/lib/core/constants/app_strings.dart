/// App-wide string constants
class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'Phimium';
  static const String appTagline = 'Khám phá Sài Gòn cùng Buddy địa phương';

  // Auth
  static const String login = 'Đăng nhập';
  static const String register = 'Đăng ký';
  static const String email = 'Email';
  static const String password = 'Mật khẩu';
  static const String confirmPassword = 'Xác nhận mật khẩu';
  static const String forgotPassword = 'Quên mật khẩu?';
  static const String fullName = 'Họ và tên';
  static const String phone = 'Số điện thoại';
  static const String birthday = 'Ngày sinh';
  static const String otp = 'Mã OTP';
  static const String verify = 'Xác thực';
  static const String dontHaveAccount = 'Chưa có tài khoản? ';
  static const String alreadyHaveAccount = 'Đã có tài khoản? ';
  static const String loginRequired = 'Bạn cần đăng nhập để dùng tính năng này.';

  // Navigation
  static const String home = 'Trang chủ';
  static const String explore = 'Khám phá';
  static const String wishlist = 'Yêu thích';
  static const String profile = 'Tài khoản';

  // Home
  static const String featuredTours = 'Tour nổi bật';
  static const String popularTours = 'Được yêu thích';
  static const String foodTours = 'Food tour - Ăn sập Sài Gòn';
  static const String historyTours = 'History tour - Dấu xưa Sài Gòn';
  static const String upcomingTrips = 'Chuyến đi sắp tới';
  static const String seeAll = 'Xem tất cả';
  static const String findBuddy = 'Tìm Buddy hợp gu';
  static const String findBuddyDesc =
      'Chọn tour, Phimium sẽ ghép bạn với Buddy địa phương phù hợp sở thích.';

  // Tour
  static const String foodTour = 'Food tour';
  static const String historyTour = 'History tour';
  static const String allTours = 'Tất cả';
  static const String itinerary = 'Lịch trình';
  static const String description = 'Giới thiệu';
  static const String reviews = 'Đánh giá';
  static const String departures = 'Lịch khởi hành';
  static const String yourBuddy = 'Buddy của bạn';
  static const String bookNow = 'Đặt tour';
  static const String perPerson = '/người';
  static const String noDepartures = 'Tour hiện chưa có lịch khởi hành.';

  // Booking
  static const String booking = 'Đặt tour';
  static const String adults = 'Người lớn';
  static const String children = 'Trẻ em';
  static const String pickupLocation = 'Điểm đón (không bắt buộc)';
  static const String couponCode = 'Mã giảm giá (không bắt buộc)';
  static const String safetyTerms = 'Tôi đồng ý với quy định an toàn của tour';
  static const String confirmBooking = 'Xác nhận đặt tour';
  static const String payNow = 'Thanh toán';
  static const String total = 'Tổng tiền';

  // Profile
  static const String myTrips = 'Chuyến đi của tôi';
  static const String myReviews = 'Đánh giá của tôi';
  static const String paymentHistory = 'Lịch sử thanh toán';
  static const String settings = 'Cài đặt';
  static const String logout = 'Đăng xuất';

  // Errors / states
  static const String errorGeneric = 'Đã xảy ra lỗi. Vui lòng thử lại.';
  static const String errorNetwork = 'Không có kết nối mạng.';
  static const String errorTimeout = 'Kết nối hết thời gian.';
  static const String errorEmpty = 'Chưa có dữ liệu.';
  static const String retry = 'Thử lại';
}
