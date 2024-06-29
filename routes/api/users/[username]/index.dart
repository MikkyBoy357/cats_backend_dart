import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/services/mongo_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String username) async {
  print('======= username =======> $username');
  final mongoService = await context.read<Future<MongoService>>();

  final userRepository = UserRepository(database: mongoService.database);
  final request = context.request;
  final method = request.method;
  final queryParams = request.uri.queryParameters;
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
