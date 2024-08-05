import 'dart:convert';

enum WsEventType { message, typing, receipt, connect }

class WsEventMessage {
  final String? id;
  final WsEventType eventType;
  final dynamic message;
  final String? senderId;

  WsEventMessage({
    this.id,
    required this.eventType,
    this.message,
    this.senderId,
  });

  factory WsEventMessage.fromJson(Map<String, dynamic> json) {
    return WsEventMessage(
      id: json['id'] as String?,
      eventType: WsEventType.values.firstWhere((e) {
        return e.name.toLowerCase() == json['eventType'];
      }),
      message: json['message'],
      senderId: json['senderId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventType': eventType.name,
      'message': message,
      'sender': senderId,
    };
  }

  WsEventMessage copyWith({
    String? id,
    WsEventType? eventType,
    dynamic message,
    String? senderId,
  }) {
    return WsEventMessage(
      id: id ?? this.id,
      eventType: eventType ?? this.eventType,
      message: message ?? this.message,
      senderId: senderId ?? this.senderId,
    );
  }

  static WsEventMessage? fromString(String message) {
    try {
      final json = jsonDecode(message) as Map<String, dynamic>;
      return WsEventMessage.fromJson(json);
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
