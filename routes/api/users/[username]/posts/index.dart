import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String username) async {
  final userRepository =
      UserRepository(database: await mongoDbPoolService.acquire());
  final postRepository =
      PostRepository(database: await mongoDbPoolService.acquire());
  final request = context.request;
  final method = request.method;
  final handler = PostRequestHandlerImpl(postRepository: postRepository);

  // get user by username
  final user = await userRepository.getQuery(UserQuery.username, username);
  printBlue('======= wildcardUser ($username) =======> ${user?.toJson()}');

  if (user == null) {
    return Response(
      body: 'User not found',
      statusCode: 404,
    );
  }

  return switch (method) {
    HttpMethod.get => await handler.handleGetPostsByUserId(
        userId: user.$_id,
      ),
    _ => Response(
        body: 'Unsupported request method: $method',
        statusCode: 405,
      ),
  };
}
