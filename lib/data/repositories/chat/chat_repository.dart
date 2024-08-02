import 'package:cats_backend/common/common.dart';
import 'package:mongo_dart/mongo_dart.dart';

abstract class ChatRepositoryImpl {
  Future<List<Chat>> getAllSaintChats({required ObjectId saintId});
  Future<Chat?> getSingleSaintChat({
    required ObjectId saintId,
    required List<ObjectId> participants,
  });
  Future<Chat?> getChatById({required ObjectId chatId});
  Future<Chat?> createChat({
    required ObjectId saintId,
    required List<ObjectId> participants,
  });

  // Get Chat with messages
  Future<List<ChatMessage>> getChatMessagesByChatId({required ObjectId chatId});
  Future<Chat?> getChatByIdWithMessages({required ObjectId chatId});

  // Send
  Future<ChatMessage?> sendMessageByChatId({
    required ObjectId chatId,
    required ObjectId senderId,
    required String message,
    String? mediaUrl,
  });

  // Future<List<Chat>> getAllChats({
  //   required ObjectId userId,
  // });
  // Future<Chat> getChatById(ObjectId chatId);
  // Future<Chat> createChat({
  //   required ObjectId userId,
  //   required ObjectId receiverId,
  // });
  // Future<ChatMessage> sendMessage({
  //   required ObjectId chatId,
  //   required ObjectId senderId,
  //   required String message,
  // });
}

class ChatRepository extends ChatRepositoryImpl {
  final Db _database;

  ChatRepository({
    required Db database,
  }) : _database = database;

  DbCollection get chatsCollection => _database.chatsCollection;
  DbCollection get chatMessagesCollection => _database.chatMessagesCollection;

  @override
  Future<List<Chat>> getAllSaintChats({
    required ObjectId saintId,
    List<ObjectId> participants = const [],
  }) async {
    // where participants contains saintId
    final result = await chatsCollection.find({
      'participants': {
        r'$all': [saintId, ...participants],
      },
    }).toList();

    final chats = result.map((chat) {
      return Chat.fromJson(chat);
    }).toList();

    return chats;
  }

  @override
  Future<Chat?> getSingleSaintChat({
    required ObjectId saintId,
    required List<ObjectId> participants,
  }) async {
    final result = await chatsCollection.findOne({
      'participants': {
        r'$all': [saintId, ...participants],
      },
    });

    if (result == null) {
      return null;
    }

    final chat = Chat.fromJson(result);

    // get chats messages
    final chatMessages = await getChatMessagesByChatId(chatId: chat.$_id);

    return chat.copyWith(chatMessages: chatMessages);
  }

  @override
  Future<Chat?> getChatById({required ObjectId chatId}) async {
    final result = await chatsCollection.findOne({'_id': chatId});

    if (result == null) {
      return null;
    }

    final chat = Chat.fromJson(result);
    return chat;
  }

  @override
  Future<Chat?> createChat({
    required ObjectId saintId,
    required List<ObjectId> participants,
  }) async {
    final chat = Chat(
      $_id: ObjectId(),
      participants: [
        saintId,
        ...participants,
      ],
    );

    final chatMap = chat.toJson();
    await chatsCollection.insert(chatMap);

    return chat;
  }

  // Get Chat with messages

  @override
  Future<List<ChatMessage>> getChatMessagesByChatId({
    required ObjectId chatId,
  }) async {
    final result = await chatMessagesCollection.find({
      'chatId': chatId,
    }).toList();

    final chatMessages = result.map((chatMessage) {
      return ChatMessage.fromJson(chatMessage);
    }).toList();

    return chatMessages;
  }

  @override
  Future<Chat?> getChatByIdWithMessages({required ObjectId chatId}) async {
    final chat = await getChatById(chatId: chatId);
    if (chat == null) {
      return null;
    }

    final chatMessages = await getChatMessagesByChatId(chatId: chat.$_id);

    return chat.copyWith(chatMessages: chatMessages);
  }

  @override
  Future<ChatMessage?> sendMessageByChatId({
    required ObjectId chatId,
    required ObjectId senderId,
    required String message,
    String? mediaUrl,
  }) async {
    final chatMessage = ChatMessage(
      id: ObjectId(),
      chatId: chatId,
      senderId: senderId,
      message: message,
      msgTimestamp: DateTime.now(),
      messageType: mediaUrl == null ? MessageType.text : MessageType.media,
      mediaUrl: mediaUrl,
    );

    final chatMessageMap = chatMessage.toJson();
    await chatMessagesCollection.insert(chatMessageMap);

    return chatMessage;
  }
}
