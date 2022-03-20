import 'dart:html';

import 'package:rollapi/rollapi.dart';

import 'settings.dart';
import 'utils.dart';
import 'dart:async';

StreamSubscription<RollState>? _watchSub;

void main() {
  final mainText = querySelector('#main-text')!;
  final rollUuidText = querySelector('#roll-uuid')!;
  final resultText = querySelector('#result-text')!;
  final resultImg = querySelector('#result-image')! as ImageElement;
  final rollNotes = querySelector('#roll-notes')!;
  final btnRoll = querySelector('#btn-roll')! as ButtonElement;

  hideImg() => (resultImg..src = '')..hide();

  final client = RollApiClient(
    minPingFrequency: Duration(milliseconds: 1000),
    password: document.cookie?.getCookie(cookieApiPwdKey),
  );

  Future<void> watch(String uuid) async {
    rollUuidText.innerText = uuid;
    rollUuidText.show();
    await _watchSub?.cancel();
    print('Watching $uuid...');
    _watchSub = client.watchRoll(uuid).listen((event) {
      print('Watch event: $event');
      if (event is RollStateWaiting) {
        resultText.innerText = event.eta != null
            ? 'Waiting... your roll should be here in '
                '~${event.eta!.difference(DateTime.now()).inSeconds} seconds...'
            : 'Waiting for the roll...';
      } else if (event is RollStateErrorExpired) {
        resultText.innerText = 'This roll has expired 😞 \nTry a new one!';
      } else if (event is RollStateErrorFailed) {
        resultText.innerText = 'Error: $event';
      } else if (event is RollStateFinished) {
        resultText.innerText = event.number.toString();
        resultImg.src = client.getImageUrl(uuid).toString();
        resultImg.show();

        rollNotes.innerText = "Psst, your roll will expire " +
            (event.ttl != null ? event.ttl!.toTimeString() : "after some time");
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

  btnRoll.show();
  btnRoll.onClick.listen((_) async {
    rollUuidText.hide();
    resultImg.hide();
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
      var txt = "You're rolling too often! " +
          (e.limitReset != null
              // Looks like getting headers doesn't work in browser
              ? "Wait ~${e.limitReset!.difference(DateTime.now()).inSeconds} "
                  "seconds ⏳ and try again 🤷"
              : "Try again later...");
      resultText.text = txt;
    } catch (e) {
      resultText.text = "Error: $e";
    }
  });

  // start watching if uuid is in url:
  final uuid = Uri.parse(window.location.href).queryParameters['uuid'];
  if (uuid != null) {
    print('already have $uuid');
    watch(uuid);
  }
}
