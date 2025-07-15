import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/config/config.dart';
import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_auth/dart_frog_auth.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

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

Future<AuthValidationResponse> getAuthResult({
  required String? token,
}) async {
  if (token == null) {
    printMagenta('Token is required');
    return AuthValidationResponse(
      isValid: false,
      errorMessage: 'Token is required',
    );
  }

  try {
    final db = await mongoDbPoolService.acquire();
    final jwtClaim = verifyJwtHS256Signature(
      token,
      Config.jwtSecret,
    );

    printMagenta('jwtClaim:');
    printMagenta(jwtClaim);

    final userId = jwtClaim.subject;
    printBlue('userId: $userId');
    if (userId == null) {
      return AuthValidationResponse(
        isValid: false,
        errorMessage: 'Invalid user id in token',
      );
    }

    final userRepository = UserRepository(database: db);
    final user = await userRepository.getQuery(UserQuery.id, userId);
    printBlue('======> Logged in as: ${user?.toJson()}');

    return AuthValidationResponse(isValid: true, user: user);
  } on JwtException catch (jwtException) {
    printBlue('JwtException: ${jwtException.message}.');
    return AuthValidationResponse(
      isValid: false,
      errorMessage: jwtException.message,
    );
  }
}

Middleware authenticationValidator({
  List<HttpMethod> excludedMethods = const [],
}) {
  return bearerAuthentication<AuthValidationResponse>(
    applies: (context) => Future.value(
      !excludedMethods.contains(context.request.method),
    ),
    authenticator: (context, token) async {
      return getAuthResult(token: token);
    },
  );
}
