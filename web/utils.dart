import 'dart:html';

extension Utils on Element {
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
