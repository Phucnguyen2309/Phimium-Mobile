import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/verify_otp_page.dart';
import '../../features/booking/presentation/pages/booking_page.dart';
import '../../features/booking/presentation/pages/my_bookings_page.dart';
import '../../features/booking/presentation/pages/payment_history_page.dart';
import '../../features/buddy/presentation/pages/buddy_workspace_page.dart';
import '../../features/explore/presentation/pages/explore_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/review/presentation/pages/my_reviews_page.dart';
import '../../features/review/presentation/pages/review_page.dart';
import '../../features/review/presentation/pages/write_review_page.dart';
import '../../features/tour/presentation/pages/tour_detail_page.dart';
import '../../features/tour/presentation/pages/tour_itinerary_page.dart';
import '../../features/wishlist/presentation/pages/wishlist_page.dart';
import 'app_shell.dart';

/// App Router (GoRouter)
class AppRouter {
  AppRouter._();

  // Route paths
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyOtp = '/verify-otp';
  static const String home = '/home';
  static const String explore = '/explore';
  static const String wishlist = '/wishlist';
  static const String profile = '/profile';
  static const String tourDetail = '/tour/:id';
  static const String tourItinerary = '/tour/:id/itinerary';
  static const String booking = '/tour/:id/book';
  static const String buddyReviews = '/buddy/:buddyId/reviews';
  static const String myBookings = '/bookings';
  static const String paymentHistory = '/payment-history';
  static const String payments = '/payments';
  static const String buddyWorkspace = '/buddy-workspace';
  static const String writeReview = '/bookings/:id/review';
  static const String myReviews = '/my-reviews';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      // Auth
      GoRoute(path: login, builder: (context, state) => const LoginPage()),
      GoRoute(path: register, builder: (context, state) => const RegisterPage()),
      GoRoute(
        path: verifyOtp,
        builder: (context, state) =>
            VerifyOtpPage(email: state.uri.queryParameters['email'] ?? ''),
      ),

      // Main shell với bottom navigation
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: home,
            pageBuilder: (context, state) => const NoTransitionPage(child: HomePage()),
          ),
          GoRoute(
            path: explore,
            pageBuilder: (context, state) => NoTransitionPage(
              child: ExplorePage(initialType: state.uri.queryParameters['type']),
            ),
          ),
          GoRoute(
            path: wishlist,
            pageBuilder: (context, state) => const NoTransitionPage(child: WishlistPage()),
          ),
          GoRoute(
            path: profile,
            pageBuilder: (context, state) => const NoTransitionPage(child: ProfilePage()),
          ),
        ],
      ),

      // Tour (full screen)
      GoRoute(
        path: tourDetail,
        builder: (context, state) => TourDetailPage(tourId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: tourItinerary,
        builder: (context, state) => TourItineraryPage(tourId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: booking,
        builder: (context, state) => BookingPage(tourId: state.pathParameters['id']!),
      ),

      GoRoute(path: payments, redirect: (context, state) => paymentHistory),

      // Booking, Payment, Buddy & Review
      GoRoute(path: myBookings, builder: (context, state) => const MyBookingsPage()),
      GoRoute(path: paymentHistory, builder: (context, state) => const PaymentHistoryPage()),
      GoRoute(path: buddyWorkspace, builder: (context, state) => const BuddyWorkspacePage()),
      GoRoute(
        path: writeReview,
        builder: (context, state) => WriteReviewPage(bookingId: state.pathParameters['id']!),
      ),
      GoRoute(path: myReviews, builder: (context, state) => const MyReviewsPage()),
      GoRoute(
        path: buddyReviews,
        builder: (context, state) => ReviewPage(
          buddyId: state.pathParameters['buddyId']!,
          buddyName: state.uri.queryParameters['name'],
        ),
      ),
    ],
  );
}
