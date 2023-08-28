import 'dart:html';

import 'package:rollapi/rollapi.dart';

import 'settings.dart';
import 'utils.dart';
import 'dart:async';

StreamSubscription<RollState>? _watchSub;

void main() {
  // final mainText = querySelector('#main-text')!;
  final resultText = querySelector('#result-text')!;
  final resultImg = querySelector('#result-image')! as ImageElement;
  final btnCopy = querySelector('#btn-copy-link')! as ButtonElement;
  final rollNotes = querySelector('#roll-notes')!;
  final btnRoll = querySelector('#btn-roll')! as ButtonElement;

  hideImg() => (resultImg..src = '')..hide();

  final client = RollApiClient(
    minPingFrequency: Duration(milliseconds: 1000),
    password: document.cookie?.getCookie(cookieApiPwdKey),
  );

  Future<void> watch(String uuid) async {
    await _watchSub?.cancel();
    print('Watching $uuid...');
    _watchSub = client.watchRoll(uuid).listen((event) {
      print('Watch event: $event');
      if (event is RollStateWaiting) {
        resultText.innerText = event.eta != null
            ? 'Waiting... '
                '~${event.eta!.difference(DateTime.now()).inSeconds}s left'
            : 'Waiting...';
      } else if (event is RollStateErrorExpired) {
        resultText.innerText = 'This roll has expired 😞 \nTry a new one!';
      } else if (event is RollStateErrorFailed) {
        resultText.innerText = 'Error: $event';
      } else if (event is RollStateFinished) {
        resultText.innerText = event.number.toString();
        resultImg.src = client.getImageUrl(uuid).toString();
        resultImg.show();
        btnCopy.show();
        rollNotes.innerText = timeUntilExpiryText(event.ttl);
        rollNotes.show();
      }

      btnRoll.disabled = event is RollStateWaiting;
      if (event is! RollStateFinished) {
        hideImg();
        rollNotes.hide();
      }
      resultText.show();
    });
    await _watchSub!.asFuture();
  }

  btnCopy.onClick.listen((_) =>
      window.navigator.clipboard?.writeText(window.location.href.toString()));
  btnRoll.show();
  btnRoll.onClick.listen((_) async {
    resultImg.hide();
    rollNotes.hide();
    btnCopy.hide();
    btnRoll.disabled = true;
    resultText.text = "Rolling...";
    resultText.show();
    try {
      final uuid = await client.roll();
      window.history.pushState(
        null,
        'rollin',
        Uri.parse(window.location.href)
            .withReplacedParams({'uuid': uuid}).toString(),
      );
      await watch(uuid);
    } on RollApiRateLimitException catch (e) {
      // Looks like getting headers doesn't work in browser
      var txt = "You're rolling too often! "
          "${e.limitReset != null ? "Wait "
              "~${e.limitReset!.difference(DateTime.now()).inSeconds} "
              "seconds ⏳ and try again 🤷" : "Try again later..."}";
      resultText.text = txt;
      // don't enable the btn - mf doesn't deserve it
    } catch (e) {
      resultText.text = "Error: $e";
      btnRoll.disabled = false;
    }
  });

  // start watching if uuid is in url:
  final uuid = Uri.parse(window.location.href).queryParameters['uuid'];
  if (uuid != null) {
    print('already have $uuid');
    watch(uuid);
  }
}
