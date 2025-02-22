import 'package:cats_backend/common/common.dart';
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

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      $_id: toObjectId(json['_id']),
      amount: json['amount'] as double,
      date: DateTime.parse(json['date'].toString()),
      description: json['description'] as String,
      senderId: json['senderId'] as ObjectId,
      receiverId: json['receiverId'] as ObjectId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': $_id,
      'amount': amount,
      'date': date.toString(),
      'description': description,
      'senderId': senderId,
      'receiverId': receiverId,
    };
  }
}
