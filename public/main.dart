import 'dart:html';

void main() {
  final button = querySelector('#hello-btn') as ButtonElement?;
  button?.onClick.listen((_) {
    window.alert('Hello from Dart!');
  });
}
