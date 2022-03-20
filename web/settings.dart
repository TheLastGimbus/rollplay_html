import 'dart:html';

const cookieApiPwdKey = 'rollplay.api-password';

extension Cookie on String {
  String? getCookie(String key) {
    if (document.cookie == null) return null;
    final cookies = document.cookie!.split('; ');
    try {
      return cookies
          .firstWhere((cookie) => cookie.startsWith(key + '='))
          .split('=')
          .last;
    } on StateError catch (e) {
      return null;
    }
  }

  void setCookie(String key, String value) =>
      document.cookie = '$key=$value; SameSite=Lax;';
}