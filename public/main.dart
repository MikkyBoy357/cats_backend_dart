import 'package:web/web.dart';

void main() {
  final button = document.querySelector('#hello-btn') as HTMLButtonElement?;

  if (button != null) {
    button.onClick.listen((event) {
      window.alert('Hello, World!');
    });
  }
}
