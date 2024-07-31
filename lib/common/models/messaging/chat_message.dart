import 'package:mongo_dart/mongo_dart.dart';

enum MessageType { text, media, event }

class ChatMessage {
  final ObjectId id;
  final ObjectId chatId;
  final ObjectId senderId;
  final DateTime msgTimestamp;
  final String message;
  final MessageType messageType;

  ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.msgTimestamp,
    required this.message,
    this.messageType = MessageType.text,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final msgTimestamp = json['msgTimestamp'];
    // print type of msgTimestamp
    print(msgTimestamp.runtimeType);
    print('OMO => ${json['msgTimestamp']}');
    return ChatMessage(
      id: json['_id'] as ObjectId,
      chatId: json['chatId'] as ObjectId,
      senderId: json['senderId'] as ObjectId,
      msgTimestamp: json['msgTimestamp'] as DateTime,
      message: json['message'] as String,
      messageType: MessageType.values.firstWhere(
        (e) => e.name == json['messageType'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'chatId': chatId,
      'senderId': senderId,
      'msgTimestamp': msgTimestamp.toString(),
      'message': message,
      'messageType': messageType.name,
    };
  }
}
