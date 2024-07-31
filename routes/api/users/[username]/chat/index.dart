import 'package:cats_backend/data/repositories/auth/user_repository.dart';
import 'package:cats_backend/data/repositories/chat/chat_repository.dart';
import 'package:cats_backend/data/request_handlers/chat.dart';
import 'package:cats_backend/helpers/helpers.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String username) async {
  print('======= username =======> $username');
  final mongoService = await context.read<Future<MongoService>>();
  final authValidationResponse = context.read<AuthValidationResponse>();

  if (!authValidationResponse.isValid) {
    return Response.json(
      statusCode: 401,
      body: 'Auth Error: ${authValidationResponse.errorMessage}',
    );
  }

  final saint = authValidationResponse.user!;

  final userRepository = UserRepository(database: mongoService.database);

  final passedUser = await userRepository.getQuery(
    UserQuery.username,
    username,
  );

  if (passedUser == null) {
    return Response.json(
      body: {'message': 'User @$username not found'},
      statusCode: 404,
    );
  }

  final chatRepository = ChatRepository(database: mongoService.database);
  final request = context.request;
  final method = request.method;
  final queryParams = request.uri.queryParameters;
  final handler = ChatRequestHandlerImpl(chatRepository: chatRepository);

  return switch (method) {
    HttpMethod.get => handler.handleGetSingleSaintChat(
        saintId: saint.$_id,
        participants: [passedUser.$_id],
      ),
    HttpMethod.post => handler.handleCreateChat(
        saintId: saint.$_id,
        participants: [passedUser.$_id],
      ),
    _ => Future.value(
        Response(
          body:
              'Unsupported request method to /${passedUser.email}/chat: $method',
          statusCode: 405,
        ),
      ),
  };

  return Response.json(body: '/${passedUser.email}/chat');
}
