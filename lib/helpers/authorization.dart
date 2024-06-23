import 'package:cats_backend/config/config.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

Middleware authorize() {
  return provider<bool>((context) {
    final request = context.request;

    final headers = request.headers;
    final authData = headers['Authorization'];
    try {
      final token = authData!.split(' ').last;

      verifyJwtHS256Signature(
        token,
        Config.jwtSecret,
      );
      return true;
    } catch (e) {
      return false;
    }
  });
}

String issueToken(String userId) {
  final claimSet = JwtClaim(
    subject: userId,
    issuer: Config.jwtIssuer,
    otherClaims: <String, dynamic>{
      'roles': ['user'],
    },
    issuedAt: DateTime.now(),
    expiry: DateTime.now().add(
      const Duration(hours: 24),
    ),
  );

  final token = issueJwtHS256(claimSet, Config.jwtSecret);
  return token;
}
