import 'dart:html';
import 'settings.dart';


void main() async {
  final form = querySelector('#form-settings')! as FormElement;
  final inputPwd = form.querySelector('#api-password')! as InputElement;

  // Fill password from cookie
  inputPwd.value =  document.cookie?.getCookie(cookieApiPwdKey) ?? '';
  form.classes.toggle('hidden');

  form.onSubmit.listen((event) {
    event.preventDefault();
    final formData = FormData(form);
    final pass = formData.get('api-password')! as String;
    // save password to cookie
    document.cookie?.setCookie(cookieApiPwdKey, pass);
  });
}

