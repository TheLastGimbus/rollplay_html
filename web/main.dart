import 'dart:html';

import 'package:rollapi/rollapi.dart';

void hide(Element e) => e.classes.add('hidden');

void show(Element e) => e.classes.remove('hidden');

void main() {
  final mainText = querySelector('#main-text')!;
  final rollUuidText = querySelector('#roll-uuid')!;
  final resultText = querySelector('#result-text')!;
  final resultImg = querySelector('#result-image')! as ImageElement;
  final btnRoll = querySelector('#btn-roll')! as ButtonElement;

  final client = RollApiClient(minPingFrequency: Duration(milliseconds: 1000));

  show(btnRoll);
  btnRoll.onClick.listen((_) async {
    hide(rollUuidText);
    hide(resultImg);
    btnRoll.disabled = true;

    resultText.text = "Rolling...";
    show(resultText);
    try {
      final stateStream = await client.roll();
      final res = await stateStream.last;
      rollUuidText.text = res.uuid;
      show(rollUuidText);
      if (res.isError) {
        resultText.text = res.toString();
        return;
      } else if (res is RollStateFinished) {
        resultText.text = res.number.toString();
        resultImg.src = client.getImageUrl(res.uuid).toString();
        show(resultImg);
      }
    } on RollApiRateLimitException catch (e) {
      var txt = "You're rolling too often! " +
          (e.limitReset != null
              // Looks like getting headers doesn't work in browser
              ? "Wait ~${DateTime.now().difference(e.limitReset!).inSeconds} "
                  "seconds ⏳ and try again 🤷"
              : "Try again later...");
      resultText.text = txt;
    } catch (e) {
      resultText.text = "Error: $e";
    } finally {
      btnRoll.disabled = false;
    }
  });
  querySelector('#output')?.text = 'Your Dart app is running.';
}
