import 'dart:html';

import '../settings.dart';
import '../utils.dart';

void main() async {
  final form = querySelector('#form-settings')! as FormElement;
  final inputPwd = form.querySelector('#api-password')! as InputElement;
  final subMsgSuccess = form.querySelector('#submission-message-success')!;
  final subMsgFail = form.querySelector('#submission-message-fail')!;

  // Fill password from cookie
  inputPwd.value = document.cookie?.getCookie(cookieApiPwdKey) ?? '';
  form.classes.toggle('hidden');

  form.onSubmit.listen((event) {
    event.preventDefault();
    final formData = FormData(form);
    final pass = formData.get('api-password')! as String;
    // save password to cookie
    document.cookie?.setCookie(
      cookieApiPwdKey,
      pass,
      maxAge: Duration(days: 365),
      secure: true,
    );

    if (document.cookie?.getCookie(cookieApiPwdKey) == pass) {
      subMsgSuccess.show();
      subMsgSuccess.fadeOut();
      subMsgFail.hide();
    } else {
      subMsgSuccess.hide();
      subMsgFail.show();
    }
  });
}
