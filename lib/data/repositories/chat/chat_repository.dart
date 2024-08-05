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

  // Get ChatMessages
  Future<ChatMessage?> getChatMessageById({required ObjectId messageId});

  // Send
  Future<ChatMessage?> sendMessageByChatId({
    required ObjectId chatId,
    required ObjectId senderId,
    required String message,
    String? mediaUrl,
  });

  // Receipt
  Future<bool?> updateMessageReadReceipt({
    required ObjectId chatId,
    required User user,
    required ReceiptPayload receiptPayload,
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
  Future<ChatMessage?> getChatMessageById({required ObjectId messageId}) async {
    final result = await chatMessagesCollection.findOne({'_id': messageId});
    if (result == null) {
      return null;
    }

    final chatMessage = ChatMessage.fromJson(result);
    return chatMessage;
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
      readReceipt: ReadReceipt.empty(),
    );

    final chatMessageMap = chatMessage.toJson();
    await chatMessagesCollection.insert(chatMessageMap);

    return chatMessage;
  }

  @override
  Future<bool?> updateMessageReadReceipt({
    required ObjectId chatId,
    required User user,
    required ReceiptPayload receiptPayload,
  }) async {
    final messageId = ObjectId.tryParse(receiptPayload.messageId);
    if (messageId == null) {
      printRed('Error: Cannot parse messageId');
      return null;
    }

    final chatMessage = await getChatMessageById(messageId: messageId);

    if (chatMessage == null) {
      printRed('Error: ChatMessage with id $messageId not found');
      return null;
    }

    return switch (receiptPayload.status) {
      ReadStatus.delivered => await () async {
          if (chatMessage.readReceipt.deliveredTo.contains(user.$_id)) {
            printYellow('Warning: Message already delivered to: ${user.$_id}');
            return null;
          }

          final res = await chatMessagesCollection.updateOne(
            where.id(chatMessage.id),
            modify.push('readReceipt.deliveredTo', user.$_id),
          );

          if (res.writeError != null) {
            printRed('Error: ${res.writeError}');
            return null;
          }

          printGreen('MessageId ${chatMessage.id} delivered to: ${user.$_id}');
          return true;
        }(),
      ReadStatus.read => await () async {
          if (chatMessage.readReceipt.readBy.contains(user.$_id)) {
            printYellow('Warning: Message already read by user ${user.$_id}');
            return null;
          }

          final res = await chatMessagesCollection.updateOne(
            where.id(chatMessage.id),
            modify.push('readReceipt.readBy', user.$_id),
          );

          if (res.writeError != null) {
            printRed('Error: ${res.writeError}');
            return null;
          }

          printGreen('MessageId ${chatMessage.id} read by: ${user.$_id}');
          return true;
        }(),
    };
  }
}
