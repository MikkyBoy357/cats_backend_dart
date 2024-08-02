import 'package:cats_backend/data/repositories/chat/chat_repository.dart';
import 'package:cats_backend/data/request_handlers/chat.dart';
import 'package:cats_backend/helpers/authentication_validation.dart';
import 'package:cats_backend/services/mongo_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  final authValidationResponse = context.read<AuthValidationResponse>();

  if (!authValidationResponse.isValid) {
    return Response.json(
      statusCode: 401,
      body: 'Auth Error: ${authValidationResponse.errorMessage}',
    );
  }

  final saint = authValidationResponse.user!;

  final chatRepository = ChatRepository(database: mongoDbService.database);
  final request = context.request;
  final method = request.method;
  final queryParams = request.uri.queryParameters;
  final handler = ChatRequestHandlerImpl(chatRepository: chatRepository);

  return switch (method) {
    HttpMethod.get => handler.handleGetAllSaintChats(saintId: saint.$_id),
    _ => Future.value(
        Response(body: 'Unsupported request method: $method', statusCode: 405),
      ),
  };

  return Response.json(body: '/chats');
}
