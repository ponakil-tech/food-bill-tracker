

class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://food-bill-tracker-api.onrender.com/api',
  );

  // Generous timeouts: the API runs on a free tier that "sleeps" after
  // inactivity and can take 30–60s to cold-start on the first request.
  static const Duration connectTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);

  static const String users = '/users';
  static const String login = '/users/login';

  static String user(String id) => '$users/$id';
  static const String foodEntries = '/food-entries';
  static String foodEntry(String id) => '$foodEntries/$id';
}
