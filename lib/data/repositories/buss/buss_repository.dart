import 'package:cats_backend/common/common.dart';
import 'package:mongo_dart/mongo_dart.dart';

abstract class BussRepositoryImpl {
  Future<Wallet> getWalletById(ObjectId walletId);
  Future<Transaction> bussTransfer({
    required ObjectId senderId,
    required ObjectId receiverId,
    required double amount,
    required String description,
  });
}

class BussRepository extends BussRepositoryImpl {
  final Db _database;

  BussRepository({
    required Db database,
  }) : _database = database;

  DbCollection get transactionsCollection => _database.transactionsCollection;

  @override
  Future<Wallet> getWalletById(ObjectId walletId) async {
    print('WalletId: $walletId');
    final result = await transactionsCollection.find({
      'senderId': walletId,
      'receiverId': walletId,
    }).toList();

    print('WalletResult: $result');

    final transactions = result.map((transaction) {
      return Transaction.fromMap(transaction);
    }).toList();

    return Wallet(
      $_id: walletId,
      transactions: transactions,
    );
  }

  @override
  Future<Transaction> bussTransfer({
    required ObjectId senderId,
    required ObjectId receiverId,
    required double amount,
    required String description,
  }) async {
    final transaction = Transaction(
      $_id: ObjectId(),
      amount: amount,
      date: DateTime.now().toUtc(),
      description: description,
      senderId: senderId,
      receiverId: receiverId,
    );

    final result = await transactionsCollection.insertOne(transaction.toMap());
    print('ResultId: ${result.id}');

    return transaction;
  }
}
