import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/config/config.dart';
import 'package:cats_backend/data/repositories/auth/user_repository.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_auth/dart_frog_auth.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class AuthValidationResponse {
  final bool isValid;
  final User? user;
  final String? errorMessage;

  AuthValidationResponse({
    required this.isValid,
    this.user,
    this.errorMessage,
  })  : assert(
          !isValid || user != null,
          'User must not be null when isValid is true',
        ),
        assert(
          isValid || errorMessage != null,
          'ErrorMessage must not be null when isValid is false',
        );
}

Middleware authenticationValidator() {
  return bearerAuthentication<AuthValidationResponse>(
    authenticator: (context, token) async {
      try {
        final mongoService = await context.read<Future<MongoService>>();
        final db = mongoService.database;
        final jwt = JWT.verify(token, SecretKey(Config.jwtSecret));

        final payload = jwt.payload as String;
        print('payload: $payload');

        final userRepository = UserRepository(database: db);
        final user = await userRepository.getById(payload);

        return AuthValidationResponse(isValid: true, user: user);
      } on JWTException catch (jwtException) {
        print('JWTException: ${jwtException.message}');
        return AuthValidationResponse(
          isValid: false,
          errorMessage: jwtException.message,
        );
      }
    },
  );
}

// String issueToken(String userId) {
//   final claimSet = JwtClaim(
//     subject: userId,
//     issuer: Config.jwtIssuer,
//     otherClaims: <String, dynamic>{
//       'roles': ['user'],
//     },
//     issuedAt: DateTime.now(),
//     expiry: DateTime.now().add(
//       const Duration(hours: 24),
//     ),
//   );
//
//   final token = issueJwtHS256(claimSet, Config.jwtSecret);
//   return token;
// }
