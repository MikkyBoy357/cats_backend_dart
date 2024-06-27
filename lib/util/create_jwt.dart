import 'package:cats_backend/config/config.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

String createJwt(
  dynamic payload, {
  Duration expiresIn = const Duration(hours: 5),
}) {
  final jwt = JWT(payload);
  return jwt.sign(SecretKey(Config.jwtSecret), expiresIn: expiresIn);
}
