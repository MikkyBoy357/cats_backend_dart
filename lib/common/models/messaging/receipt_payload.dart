import 'package:cats_backend/common/models/models.dart';

/// This is what a payload clients emit to the socket
/// to indicate that they have read a message

class ReceiptPayload {
  final String messageId;
  final ReadStatus status;

  ReceiptPayload({
    required this.messageId,
    required this.status,
  });

  factory ReceiptPayload.fromJson(Map<String, dynamic> json) {
    return ReceiptPayload(
      messageId: json['messageId'] as String,
      status: ReadStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'status': status.name,
    };
  }
}
