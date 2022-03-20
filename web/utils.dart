import 'dart:html';

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
