/// API endpoint constants - khớp với BE Spring Boot (thư mục BE/)
///
/// baseUrl mặc định trỏ tới BE chạy local cổng 8080.
/// - Android emulator: http://10.0.2.2:8080
/// - iOS simulator / web: http://localhost:8080
/// Có thể ghi đè bằng API_BASE_URL trong file .env
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://10.0.2.2:8080';

  // Auth  (AuthController - /api/auth)
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String verifyOtp = '/api/auth/verify-otp';
  static const String resendOtp = '/api/auth/resend-otp';
  static const String refreshToken = '/api/auth/refresh';
  static const String logout = '/api/auth/logout';
  static const String me = '/api/auth/me';

  // Tour  (ActivityController - /api/activity)
  static const String tours = '/api/activity/getAll';
  static String tourDetail(String id) => '/api/activity/$id';
  static const String joinedTours = '/api/activity/joined';
  static String itineraryStops(String tourId) =>
      '/api/activity/$tourId/itinerary-stops';

  // Booking  (RegistrationController - /api/v1/registrations)
  static const String registrations = '/api/v1/registrations';
  static const String myRegistrations = '/api/v1/registrations/me';
  static String cancelRegistration(String id) =>
      '/api/v1/registrations/$id/cancel';

  // Payment  (PaymentController - /api/payment)
  static String createPayment(String registrationId) =>
      '/api/payment/registration/$registrationId';
  static const String myPayments = '/api/payment/me';

  // Review  (FeedBackController - /api/feedback)
  static String createReview(String registrationId) =>
      '/api/feedback/registrations/$registrationId';
  static const String myReviews = '/api/feedback/me';
  static String buddyReviews(String buddyId) => '/api/feedback/buddies/$buddyId';
}
