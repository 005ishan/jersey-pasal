class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - change this for production
  // static const String baseUrl = 'http://10.0.2.2:3000/api/v1';
  static const String baseUrl = 'http://192.168.137.1:3000/api/v1';
  // For Android Emulator use: 'http://10.0.2.2:3000/api/v1'
  // For iOS Simulator use: 'http://localhost:5000/api/v1'
  // For Physical Device use your computer's IP: 'http://192.168.x.x:5000/api/v1'

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ============ Auth / User Endpoints ============
  static const String users = '/users';
  static const String register = '/users/register';
  static const String login = '/users/login';
  static String userById(String id) => '/users/$id';
  static String userProfilePicture(String id) => '/users/$id/profile-picture';
  static String updateUserProfile(String id) => '/users/$id/update';

  // ============ Product / Item Endpoints ============
  static const String products = '/products';
  static String productById(String id) => '/products/$id';
  static String productClaim(String id) => '/products/$id/claim'; // optional

  // ============ Category Endpoints ============
  static const String categories = '/categories';
  static String categoryById(String id) => '/categories/$id';

  // ============ Orders Endpoints ============
  static const String orders = '/orders';
  static String orderById(String id) => '/orders/$id';

  // ============ Review / Comment Endpoints ============
  static const String reviews = '/reviews';
  static String reviewById(String id) => '/reviews/$id';
  static String reviewsByProduct(String productId) =>
      '/reviews/product/$productId';
  static String reviewLike(String id) => '/reviews/$id/like';
}
