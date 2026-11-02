import 'package:flutter/foundation.dart';

/// API endpoint constants - khớp với BE Spring Boot (thư mục BE/)
///
/// baseUrl mặc định trỏ tới BE chạy local cổng 8080:
/// - Android emulator: http://10.0.2.2:8080
/// - Web / iOS simulator / Desktop: http://localhost:8080
/// Có thể ghi đè bằng API_BASE_URL trong file .env
class ApiConstants {
  ApiConstants._();

  static String get baseUrl =>
      (kIsWeb || defaultTargetPlatform != TargetPlatform.android)
          ? 'http://localhost:8080'
          : 'http://10.0.2.2:8080';

  // Auth  (AuthController - /api/auth)
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String verifyOtp = '/api/auth/verify-otp';
  static const String resendOtp = '/api/auth/resend-otp';
  static const String refreshToken = '/api/auth/refresh';
  static const String logout = '/api/auth/logout';
  static const String me = '/api/auth/me';

  // Tour  (ActivityController - /api/activity & GuidelineController - /api/v1/activities)
  static const String tours = '/api/activity/getAll';
  static String tourDetail(String id) => '/api/activity/$id';
  static const String joinedTours = '/api/activity/joined';
  static String itineraryStops(String tourId) =>
      '/api/activity/$tourId/itinerary-stops';
  static String tourGuidelines(String tourId) =>
      '/api/v1/activities/$tourId/guidelines';

  // Pricing (PricingController - /api/v1/pricing)
  static const String pricingQuote = '/api/v1/pricing/quote';

  // Booking  (RegistrationController - /api/v1/registrations)
  static const String registrations = '/api/v1/registrations';
  static const String myRegistrations = '/api/v1/registrations/me';
  static String cancelRegistration(String id) =>
      '/api/v1/registrations/$id/cancel';
  static String checkInRegistration(String id) =>
      '/api/v1/registrations/$id/check-in';

  // Payment  (PaymentController - /api/payment)
  static String createPayment(String registrationId) =>
      '/api/payment/registration/$registrationId';
  static const String myPayments = '/api/payment/me';
  static String paymentDetail(String id) => '/api/payment/$id';

  // Review  (FeedBackController - /api/feedback)
  static String createReview(String registrationId) =>
      '/api/feedback/registrations/$registrationId';
  static const String myReviews = '/api/feedback/me';
  static String buddyReviews(String buddyId) => '/api/feedback/buddies/$buddyId';

  // Buddy  (BuddyController - /api/buddies)
  static const String buddyActivities = '/api/buddies/getActivityByBuddy';
  static const String buddyMySchedules = '/api/buddies/me/schedules';
  static String buddyTourMembers(String departureId) =>
      '/api/buddies/me/schedules/$departureId/members';
  static String buddyCheckInMember(String departureId, String registrationId) =>
      '/api/buddies/me/schedules/$departureId/members/$registrationId/check-in';
  static const String buddyUpdateStatus = '/api/buddies/me/status';
}
