import 'dart:convert';

import 'package:cats_backend/data/repositories/repositories.dart';
import 'package:cats_backend/data/request_handlers/request_handlers.dart';
import 'package:cats_backend/helpers/helpers.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  print('======= chatId =======> $id');
  final authValidationResponse = context.read<AuthValidationResponse>();

  if (!authValidationResponse.isValid) {
    return Response.json(
      statusCode: 401,
      body: 'Auth Error: ${authValidationResponse.errorMessage}',
    );
  }

  final saint = authValidationResponse.user!;

  final body = await context.request.body();
  print('LeBody ==> $body');
  final bodyJson = jsonDecode(body) as Map<String, dynamic>;
  print('LeJSON ==> $bodyJson');

  final chatId = ObjectId.tryParse(id);
  if (chatId == null) {
    return Response.json(body: 'Error: Cannot Parse Invalid Chat ID.');
  }

  final chatRepository = ChatRepository(database: mongoDbService.database);
  final request = context.request;
  final method = request.method;
  final handler = ChatRequestHandlerImpl(chatRepository: chatRepository);

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
    HttpMethod.post => () async {
        final formData = await request.formData();

        return handler.handleSendMessageByChatId(
          chatId: chatId,
          senderId: saint.$_id,
          formData: formData,
        );
      }(),
    _ => Future.value(
        Response(
          body: 'Unsupported request method to /chats/$id: $method',
          statusCode: 405,
        ),
      ),
  };
}
