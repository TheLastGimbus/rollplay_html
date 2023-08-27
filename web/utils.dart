import 'dart:html';

import 'package:intl/intl.dart';

extension ElementUtils on Element {
  void hide() => classes.add('hidden');

  void show() => classes.remove('hidden');

  void restartClass(String className) {
    classes.remove(className);
    offsetWidth;
    classes.add(className);
  }

  void fadeOut() {
    restartClass('fade-out');
  }
}

extension UriUtils on Uri {
  Uri withReplacedParams(Map<String, dynamic> params) {
    final query = Map<String, dynamic>.from(queryParameters);
    query.addAll(params);
    return replace(queryParameters: query);
  }
}

extension DateTimeUtils on DateTime {
  String toTimeString() =>
      (day == DateTime.now().day
          ? 'today, '
          : DateFormat('EEEE, ').format(this)) +
      DateFormat("H:m").format(this);
}

String timeUntilExpiryText(DateTime? ttl) => "Psst, your roll will be visible "
    "${ttl != null ? "until ${ttl.toTimeString()}" : "only for some time"}";
