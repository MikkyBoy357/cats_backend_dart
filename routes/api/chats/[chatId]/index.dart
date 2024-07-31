import 'dart:convert';

import 'package:cats_backend/data/repositories/repositories.dart';
import 'package:cats_backend/data/request_handlers/request_handlers.dart';
import 'package:cats_backend/helpers/helpers.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  print('======= chatId =======> $id');
  final mongoService = await context.read<Future<MongoService>>();
  final authValidationResponse = context.read<AuthValidationResponse>();

  if (!authValidationResponse.isValid) {
    return Response.json(
      statusCode: 401,
      body: 'Auth Error: ${authValidationResponse.errorMessage}',
    );
  }

  final saint = authValidationResponse.user!;

  final chatId = ObjectId.tryParse(id);
  if (chatId == null) {
    return Response.json(body: 'Error: Cannot Parse Invalid Chat ID.');
  }

  final chatRepository = ChatRepository(database: mongoService.database);
  final request = context.request;
  final method = request.method;
  final queryParams = request.uri.queryParameters;
  final handler = ChatRequestHandlerImpl(chatRepository: chatRepository);

  final body = await request.body();
  final bodyJson = jsonDecode(body) as Map<String, dynamic>;

  final currentChat = await chatRepository.getChatById(chatId: chatId);

  if (currentChat == null) {
    return Response.json(
      body: 'Chat not found',
      statusCode: 404,
    );
  }

  if (!currentChat.participants.contains(saint.$_id)) {
    return Response.json(
      body: {'message': 'Unauthorized: Saint not a participant in this chat'},
    );
  }

  return switch (method) {
    HttpMethod.get => handler.handleGetChatById(
        chatId: chatId,
      ),
    HttpMethod.post => () {
        final message = bodyJson['message'] as String?;
        if (message == null || message.isEmpty) {
          return Future.value(
            Response.json(
              body: {
                'message': 'Error: Message cannot be empty nor null.',
              },
              statusCode: 400,
            ),
          );
        }

        return handler.handleSendMessageByChatId(
          chatId: chatId,
          senderId: saint.$_id,
          message: message,
        );
      }(),
    _ => Future.value(
        Response(
          body: 'Unsupported request method to /chats/$id: $method',
          statusCode: 405,
        ),
      ),
  };

  return Response.json(body: 'Chats Endpoint not yet implemented.');
}
