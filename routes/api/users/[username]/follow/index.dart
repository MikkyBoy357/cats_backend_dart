import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/helpers/helpers.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String username) async {
  printMagenta('======= username =======> $username');
  final authValidationResponse = context.read<AuthValidationResponse>();

  if (!authValidationResponse.isValid) {
    return Response.json(
      statusCode: 401,
      body: 'Auth Error: ${authValidationResponse.errorMessage}',
    );
  }

  final saint = authValidationResponse.user!;

  final userRepository =
      UserRepository(database: await mongoDbPoolService.acquire());
  final request = context.request;
  final method = request.method;
  final handler = UserRequestHandlerImpl(userRepository: userRepository);

  // get user by username
  final passedUser = await userRepository.getQuery(
    UserQuery.username,
    username,
  );
  printGreen(
    '======= wildcardUser ($username) =======> ${passedUser?.toJson()}',
  );

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
