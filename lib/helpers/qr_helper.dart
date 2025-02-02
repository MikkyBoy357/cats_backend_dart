import 'package:image/image.dart' as img;
import 'package:qr/qr.dart';

class QrResult {
  final QrCode qrCode;
  final QrImage qrImage;
  final img.Image image;
  final List<int> pngData;

  QrResult({
    required this.qrCode,
    required this.qrImage,
    required this.image,
    required this.pngData,
  });
}

Future<QrResult> generateQrCode(String data) async {
  final qrCode = QrCode(7, QrErrorCorrectLevel.L)..addData(data);
  final qrImage = QrImage(qrCode);

  final size = qrCode.moduleCount * 10;
  final image = img.Image(width: size, height: size, numChannels: 4);
  img.fill(image, color: img.ColorUint8.rgb(255, 255, 255));

  for (var y = 0; y < qrImage.moduleCount; y++) {
    for (var x = 0; x < qrImage.moduleCount; x++) {
      if (qrImage.isDark(x, y)) {
        for (var i = 0; i < 10; i++) {
          for (var j = 0; j < 10; j++) {
            image.setPixel(
              x * 10 + i,
              y * 10 + j,
              img.ColorUint8.rgb(146, 115, 235),
            );
          }
        }
      }
    }
  }

  final pngData = img.encodePng(image);

  return QrResult(
    qrCode: qrCode,
    qrImage: qrImage,
    image: image,
    pngData: pngData,
  );
}
