import 'package:cats_backend/common/common.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Chat {
  final ObjectId $_id;
  final List<ObjectId> participants;
  final List<ChatMessage>? chatMessages;

  Chat({
    required this.$_id,
    required this.participants,
    this.chatMessages = const [],
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      $_id: json['_id'] as ObjectId,
      participants: (json['participants'] as List).map((e) {
        return e as ObjectId;
      }).toList(),
      chatMessages: (json['chatMessages'] as List).map((e) {
        return ChatMessage.fromJson(e as Map<String, dynamic>);
      }).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': $_id,
      'participants': participants,
      'chatMessages': chatMessages?.map((e) {
        return e.toJson();
      }).toList(),
    };
  }

  Chat copyWith({
    ObjectId? $_id,
    List<ObjectId>? participants,
    List<ChatMessage>? chatMessages,
  }) {
    return Chat(
      $_id: $_id ?? this.$_id,
      participants: participants ?? this.participants,
      chatMessages: chatMessages ?? this.chatMessages,
    );
  }
}
