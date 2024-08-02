import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/helpers/authentication_validation.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String username) async {
  print('======= username =======> $username');
  final authValidationResponse = context.read<AuthValidationResponse>();

  if (!authValidationResponse.isValid) {
    return Response.json(
      statusCode: 401,
      body: 'Auth Error: ${authValidationResponse.errorMessage}',
    );
  }

  final saint = authValidationResponse.user!;

  final userRepository = UserRepository(database: mongoDbService.database);
  final request = context.request;
  final method = request.method;
  final queryParams = request.uri.queryParameters;
  final handler = UserRequestHandlerImpl(userRepository: userRepository);

  // get user by username
  final passedUser = await userRepository.getQuery(
    UserQuery.username,
    username,
  );
  print('======= wildcardUser ($username) =======> ${passedUser?.toJson()}');

  if (passedUser == null) {
    return Response(
      body: 'User @$username not found',
      statusCode: 404,
    );
  }

  return switch (method) {
    HttpMethod.post => await handler.postUserFollowers(
        FollowedFollower(
          followerId: saint.$_id,
          followedId: passedUser.$_id,
        ),
      ),
    _ => Response(
        body: 'Unsupported request method: $method',
        statusCode: 405,
      ),
  };
}
