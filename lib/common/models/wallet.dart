import 'package:cats_backend/common/models/transaction.dart';

class Wallet {
  double balance;
  List<Transaction> transactions;

  Wallet({
    required this.balance,
    required this.transactions,
  });

  factory Wallet.fromMap(Map<String, dynamic> map) {
    return Wallet(
      balance: map['balance'] as double,
      transactions: (map['transactions'] as List<Map<String, dynamic>>)
          .map((transaction) => Transaction.fromMap(transaction))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'balance': balance,
      'transactions':
          transactions.map((transaction) => transaction.toMap()).toList(),
    };
  }
}
