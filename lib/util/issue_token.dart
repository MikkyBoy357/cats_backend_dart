import 'package:cats_backend/config/config.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

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
