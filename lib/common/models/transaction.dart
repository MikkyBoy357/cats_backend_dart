import 'package:mongo_dart/mongo_dart.dart';

class Transaction {
  final ObjectId $_id;
  final double amount;
  final DateTime date;
  final String description;
  final ObjectId senderId;
  final ObjectId receiverId;

  Transaction({
    required this.$_id,
    required this.amount,
    required this.date,
    required this.description,
    required this.senderId,
    required this.receiverId,
  });

  bool idIsSender(ObjectId id) => senderId == id;
  bool idIsReceiver(ObjectId id) => receiverId == id;

  Transaction.fromMap(Map<String, dynamic> map)
      : $_id = map['_id'] as ObjectId,
        amount = map['amount'] as double,
        date = DateTime.parse(map['date'] as String),
        description = map['description'] as String,
        senderId = map['senderId'] as ObjectId,
        receiverId = map['receiverId'] as ObjectId;

  Map<String, dynamic> toMap() {
    return {
      '_id': $_id,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
      'senderId': senderId,
      'receiverId': receiverId,
    };
  }
}
