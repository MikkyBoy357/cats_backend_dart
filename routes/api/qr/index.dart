import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/config/config.dart';
import 'package:cats_backend/helpers/helpers.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:image/image.dart' as img;

extension StringCleanup on String {
  String cleanWhitespace() {
    return replaceAll(RegExp(r'\s{2,}'), ' ').trim();
  }
}

Future<Response> onRequest(RequestContext context) async {
  // accept only POST requests

  final request = context.request;
  final method = request.method;

  final params = request.uri.queryParameters;

  return switch (method) {
    /// GET request
    /// Encrypt the QR code key with AES256
    /// And return the QR code of the encrypted input as a PNG image
    HttpMethod.get => () async {
        final keyword = params['keyWord'];
        if (keyword == null) {
          return Response.json(
            body: 'Query Param keyWord is required',
            statusCode: 400,
          );
        }
        final keyWord = params['keyWord'].toString().cleanWhitespace();
        printBlue('cleanKeyWord: $keyWord');

        printMagenta('keyWord: $keyWord');
        printMagenta('keyWordTrim: ${keyWord.trim()}');

        printMagenta('Key: ${Config.qrCodeKey}');

        final aes256 = keyWord.toString().aes256Encrypt(Config.qrCodeKey);
        printMagenta('sha256: $aes256');

        final hello = aes256.aes256Decrypt(Config.qrCodeKey);
        printYellow('hello: $hello');

        final qrResult = await generateQrCode(aes256);
        final pngData = img.encodePng(qrResult.image);

        // Return the PNG as a binary response
        return Response.bytes(
          body: pngData,
          headers: {
            'Content-Type': 'image/png',
          },
        );
      }(),

    /// POST request
    /// Decrypt the input using AES256 and return the decrypted value
    HttpMethod.post => () async {
        final body = await request.tryJson;
        if (body == null) {
          return Response.json(
            body: 'Invalid JSON body',
            statusCode: 400,
          );
        }

        final keyWord = body['keyWord'];
        if (keyWord == null) {
          return Response.json(
            body: 'keyWord is required',
            statusCode: 400,
          );
        }

        try {
          final decrypted = keyWord.toString().aes256Decrypt(Config.qrCodeKey);
          return Response.json(
            body: {
              'status': 'success',
              'encrypted': keyWord,
              'decrypted': decrypted,
            },
          );
        } on Exception catch (e) {
          return Response.json(
            body: {
              'error': e.toString(),
            },
            statusCode: 400,
          );
        }
      }(),
    _ => Future.value(
        Response.json(
          body: 'Method not allowed',
          statusCode: 405,
        ),
      ),
  };
}
