import 'dart:html';

import 'package:rollapi/rollapi.dart';

import 'settings.dart';

void hide(Element e) => e.classes.add('hidden');

void show(Element e) => e.classes.remove('hidden');

void main() {
  final mainText = querySelector('#main-text')!;
  final rollUuidText = querySelector('#roll-uuid')!;
  final resultText = querySelector('#result-text')!;
  final resultImg = querySelector('#result-image')! as ImageElement;
  final btnRoll = querySelector('#btn-roll')! as ButtonElement;

  final client = RollApiClient(
    minPingFrequency: Duration(milliseconds: 1000),
    password: document.cookie?.getCookie(cookieApiPwdKey),
  );

  show(btnRoll);
  btnRoll.onClick.listen((_) async {
    hide(rollUuidText);
    hide(resultImg);
    btnRoll.disabled = true;

    resultText.text = "Rolling...";
    show(resultText);
    try {
      final uuid = await client.roll();
      final res = await client.watchRoll(uuid).last;
      rollUuidText.text = uuid;
      show(rollUuidText);
      if (res.isError) {
        resultText.text = res.toString();
        return;
      } else if (res is RollStateFinished) {
        resultText.text = res.number.toString();
        resultImg.src = client.getImageUrl(uuid).toString();
        show(resultImg);
      }
    } on RollApiRateLimitException catch (e) {
      var txt = "You're rolling too often! " +
          (e.limitReset != null
              // Looks like getting headers doesn't work in browser
              ? "Wait ~${e.limitReset!.difference(DateTime.now()).inSeconds} "
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
