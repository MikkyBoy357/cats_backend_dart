import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/config/config.dart';
import 'package:cats_backend/data/repositories/auth/user_repository.dart';
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
    print('Token is required');
    return AuthValidationResponse(
      isValid: false,
      errorMessage: 'Token is required',
    );
  }

  try {
    final db = mongoDbService.database;
    final jwtClaim = verifyJwtHS256Signature(
      token,
      Config.jwtSecret,
    );

    print('jwtClaim:');
    print(jwtClaim);

    final userId = jwtClaim.subject;
    print('userId: $userId');
    if (userId == null) {
      return AuthValidationResponse(
        isValid: false,
        errorMessage: 'Invalid user id in token',
      );
    }

    final userRepository = UserRepository(database: db);
    final user = await userRepository.getQuery(UserQuery.id, userId);
    print('======> Logged in as: ${user?.toJson()}');

    return AuthValidationResponse(isValid: true, user: user);
  } on JwtException catch (jwtException) {
    print('JwtException: ${jwtException.message}.');
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
