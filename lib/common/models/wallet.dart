import 'package:cats_backend/common/models/transaction.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Wallet {
  final ObjectId $_id;
  final List<Transaction> transactions;

  double get balance {
    return transactions.fold(
      0,
      (previousValue, element) {
        if (element.senderId == $_id) {
          return previousValue - element.amount;
        } else {
          return previousValue + element.amount;
        }
      },
    );
  }

  Wallet({
    required this.$_id,
    required this.transactions,
  });

  factory Wallet.fromJson(Map<String, dynamic> map) {
    return Wallet(
      $_id: map['_id'] as ObjectId,
      transactions: (map['transactions'] as List<Map<String, dynamic>>)
          .map((transaction) => Transaction.fromMap(transaction))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': $_id,
      'transactions': transactions.map((transaction) {
        return transaction.toMap();
      }).toList(),
    };
  }
}
