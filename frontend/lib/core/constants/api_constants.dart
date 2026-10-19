/// API endpoint constants
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://localhost:8080/api/v1';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';

  // Drama
  static const String dramas = '/dramas';
  static const String trending = '/dramas/trending';
  static const String categories = '/categories';
  static const String episodes = '/episodes';

  // Search
  static const String search = '/search';

  // User
  static const String profile = '/users/profile';
  static const String updateProfile = '/users/profile';

  // Bookmark
  static const String bookmarks = '/bookmarks';

  // Comment & Rating
  static const String comments = '/comments';
  static const String ratings = '/ratings';

  // Payment
  static const String coinPackages = '/payments/packages';
  static const String purchase = '/payments/purchase';
  static const String transactions = '/payments/transactions';
  static const String coinBalance = '/payments/balance';
}
