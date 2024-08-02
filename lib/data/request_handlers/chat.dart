import 'package:cats_backend/data/data.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

abstract class ChatRequestHandler {
  Future<Response> handleGetAllSaintChats({
    required ObjectId saintId,
    List<ObjectId> participants,
  });
  Future<Response> handleGetSingleSaintChat({
    required ObjectId saintId,
    required List<ObjectId> participants,
  });

  Future<Response> handleGetChatById({
    required ObjectId chatId,
  });

  Future<Response> handleCreateChat({
    required ObjectId saintId,
    required List<ObjectId> participants,
  });

  //
  Future<Response> handleSendMessageByChatId({
    required ObjectId chatId,
    required ObjectId senderId,
    required String message,
  });
}

class ChatRequestHandlerImpl implements ChatRequestHandler {
  final ChatRepository _chatRepository;

  const ChatRequestHandlerImpl({
    required ChatRepository chatRepository,
  }) : _chatRepository = chatRepository;

  @override
  Future<Response> handleGetAllSaintChats({
    required ObjectId saintId,
    List<ObjectId> participants = const [],
  }) async {
    print('===> GET <==> Chat:');
    final chats = await _chatRepository.getAllSaintChats(saintId: saintId);

    return Response.json(
      body: chats,
      statusCode: chats.isNotEmpty ? 200 : 404,
    );
  }

  @override
  Future<Response> handleGetSingleSaintChat({
    required ObjectId saintId,
    required List<ObjectId> participants,
  }) async {
    print('===> GET <==> Chat:');
    final chat = await _chatRepository.getSingleSaintChat(
      saintId: saintId,
      participants: participants,
    );

    if (chat == null) {
      return Response.json(
        body: {
          'message': 'Chat not found',
          'info': 'Saint $saintId has no chat with $participants',
        },
        statusCode: 404,
      );
    }

    return Response.json(
      body: chat,
    );
  }

  @override
  Future<Response> handleGetChatById({
    required ObjectId chatId,
  }) async {
    print('===> GET <==> Chat:');
    final chat = await _chatRepository.getChatByIdWithMessages(chatId: chatId);

    if (chat == null) {
      return Response.json(
        body: {
          'message': 'Chat not found',
          'info': 'Chat $chatId not found',
        },
        statusCode: 404,
      );
    }

    return Response.json(
      body: chat,
    );
  }

  @override
  Future<Response> handleCreateChat({
    required ObjectId saintId,
    required List<ObjectId> participants,
  }) async {
    print('===> POST <==> Chat:');
    if (participants.isEmpty) {
      return Response.json(
        body: {
          'message': 'Participants list cannot be empty',
        },
        statusCode: 400,
      );
    }

    final existingChat = await _chatRepository.getSingleSaintChat(
      saintId: saintId,
      participants: participants,
    );

    if (existingChat != null) {
      return Response.json(
        body: {
          'message': 'Chat already exists',
          'info': 'Saint $saintId already has a chat with $participants',
          'chat': existingChat,
        },
        statusCode: 409,
      );
    }

    final chat = await _chatRepository.createChat(
      saintId: saintId,
      participants: participants,
    );

    return Response.json(
      body: chat,
      statusCode: 201,
    );
  }

  @override
  Future<Response> handleSendMessageByChatId({
    required ObjectId chatId,
    required ObjectId senderId,
    required String? message,
  }) async {
    print('===> POST <==> Chat:');

    if (message == null || message.isEmpty) {
      return Response.json(
        body: {
          'message': 'Message cannot be empty nor null',
        },
        statusCode: 400,
      );
    }

    final chat = await _chatRepository.getChatById(chatId: chatId);

    if (chat == null) {
      return Response.json(
        body: {
          'message': 'Chat not found',
          'info': 'Chat $chatId not found',
        },
        statusCode: 404,
      );
    }

    final chatMessage = await _chatRepository.sendMessageByChatId(
      chatId: chatId,
      senderId: senderId,
      message: message,
    );

    return Response.json(
      body: chatMessage,
      statusCode: 201,
    );
  }
}
