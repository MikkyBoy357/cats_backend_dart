import 'package:mongo_dart/mongo_dart.dart';

class Transaction {
  ObjectId $_id;
  double amount;
  DateTime date;
  String description;

  Transaction({
    required this.$_id,
    required this.amount,
    required this.date,
    required this.description,
  });

  Transaction.fromMap(Map<String, dynamic> map)
      : $_id = map['_id'] as ObjectId,
        amount = map['amount'] as double,
        date = DateTime.parse(map['date'] as String),
        description = map['description'] as String;

  Map<String, dynamic> toMap() {
    return {
      '_id': $_id,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
    };
  }
}
