class AuthSession
{
  static String? token;

  static bool get isLoggedIn => token != null && token!.isNotEmpty;

  static void setToken(String newToken) {
    token = newToken;
  }

  static void clear() {
    token = null;
  }
}
