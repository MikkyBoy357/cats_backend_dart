import 'package:mongo_dart/mongo_dart.dart';

enum ReadStatus { delivered, read }

class ReadReceipt {
  final List<ObjectId> deliveredTo;
  final List<ObjectId> readBy;

  ReadReceipt({
    required this.deliveredTo,
    required this.readBy,
  });

  factory ReadReceipt.fromJson(Map<String, dynamic> json) {
    return ReadReceipt(
      deliveredTo:
          (json['deliveredTo'] as List).map((e) => e as ObjectId).toList(),
      readBy: (json['readBy'] as List).map((e) => e as ObjectId).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deliveredTo': deliveredTo.map((e) => e).toList(),
      'readBy': readBy.map((e) => e).toList(),
    };
  }

  ReadReceipt copyWith({
    List<ObjectId>? deliveredTo,
    List<ObjectId>? readBy,
  }) {
    return ReadReceipt(
      deliveredTo: deliveredTo ?? this.deliveredTo,
      readBy: readBy ?? this.readBy,
    );
  }

  @override
  String toString() => '{ deliveredTo: $deliveredTo, readBy: $readBy }';

  factory ReadReceipt.empty() {
    return ReadReceipt(deliveredTo: [], readBy: []);
  }
}
