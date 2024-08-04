import 'package:mongo_dart/mongo_dart.dart';

enum MessageType { text, media, event }

class ChatMessage {
  final ObjectId id;
  final ObjectId chatId;
  final ObjectId senderId;
  final DateTime msgTimestamp;
  final String message;
  final MessageType messageType;
  final String? mediaUrl;

  ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.msgTimestamp,
    required this.message,
    this.messageType = MessageType.text,
    this.mediaUrl,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'] as ObjectId,
      chatId: json['chatId'] as ObjectId,
      senderId: json['senderId'] as ObjectId,
      msgTimestamp: json['msgTimestamp'] != null
          ? DateTime.parse(json['msgTimestamp'].toString())
          : DateTime.now(),
      message: json['message'] as String,
      messageType: MessageType.values.firstWhere(
        (e) => e.name == json['messageType'],
      ),
      mediaUrl: json['mediaUrl'] as String?,
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
      'mediaUrl': mediaUrl,
    };
  }
}
