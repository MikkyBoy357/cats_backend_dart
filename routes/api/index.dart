import 'package:cats_backend/helpers/helpers.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:image/image.dart' as img;

Future<Response> onRequest(RequestContext context) async {
  // Generate the QR code
  final ip = await getPublicIpAddress();
  final qrResult = await generateQrCode('http://$ip:8080/index.html');

  // Encode the image to PNG
  final pngData = img.encodePng(qrResult.image);

  // Return the PNG as a binary response
  return Response.bytes(
    body: pngData,
    headers: {
      'Content-Type': 'image/png',
    },
  );
}
