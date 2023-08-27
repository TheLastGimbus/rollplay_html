import 'dart:html';

const cookieApiPwdKey = 'rollplay.api-password';

extension Cookie on String {
  String? getCookie(String key) {
    if (document.cookie == null) return null;
    final cookies = document.cookie!.split('; ');
    try {
      return cookies
          .firstWhere((cookie) => cookie.startsWith('$key='))
          .split('=')
          .last;
    } on StateError catch (_) {
      return null;
    }
  }

  void setCookie(
    String key,
    String value, {
    Duration maxAge = const Duration(days: 365),
    bool secure = true,
    String path = '/',
  }) =>
      document.cookie = '$key=$value; '
          'Max-Age=${maxAge.inSeconds}; '
          'Path=$path; '
          '${secure ? 'Secure; ' : ''}'
          'SameSite=Lax; ';
}
