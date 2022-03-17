import 'dart:html';

import 'package:rollapi/rollapi.dart' as roll;

void hide(Element e) => e.classes.add('hidden');

void show(Element e) => e.classes.remove('hidden');

void main() {
  final mainText = querySelector('#main-text')!;
  final rollUuidText = querySelector('#roll-uuid')!;
  final resultText = querySelector('#result-text')!;
  final resultImg = querySelector('#result-image')! as ImageElement;
  final btnRoll = querySelector('#btn-roll')! as ButtonElement;

  show(btnRoll);
  btnRoll.onClick.listen((_) async {
    hide(rollUuidText);
    hide(resultImg);
    btnRoll.disabled = true;

    resultText.text = "Rolling...";
    show(resultText);
    final req = await roll.makeRequest();

    rollUuidText.text = req.uuid;
    show(rollUuidText);

    final res = await req.stateStream.last;
    if (res.key != roll.RequestState.finished) {
      resultText.text = "Error: ${res.value}";
      return;
    }
    final number = res.value as int;
    resultText.text = number.toString();
    resultImg.src = roll.API_BASE_URL + 'image/' + req.uuid;
    show(resultImg);

    btnRoll.disabled = false;
  });
  querySelector('#output')?.text = 'Your Dart app is running.';
}
