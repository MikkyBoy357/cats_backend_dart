import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String username) async {
  printGreen('======= username =======> $username');

  final userRepository = UserRepository(
    database: await mongoDbPoolService.acquire(),
  );
  final request = context.request;
  final method = request.method;
  final handler = UserRequestHandlerImpl(userRepository: userRepository);

  return switch (method) {
    HttpMethod.get => await handler.getUserByQuery(
        UserQuery.username,
        username,
      ),
    _ => Response(
        body: 'Unsupported request method: $method',
        statusCode: 405,
      ),
  };
}
