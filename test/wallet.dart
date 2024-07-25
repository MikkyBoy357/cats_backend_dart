import 'package:cats_backend/common/common.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  final myWalletId = ObjectId();
  final friendWalletId = ObjectId();

  final myTransactions = <Transaction>[
    Transaction(
      $_id: ObjectId(),
      amount: 50,
      date: DateTime.now().subtract(
        const Duration(hours: 23),
      ),
      description: 'Payment',
      senderId: friendWalletId,
      receiverId: myWalletId,
    ),
    Transaction(
      $_id: ObjectId(),
      amount: 50,
      date: DateTime.now().subtract(
        const Duration(hours: 23),
      ),
      description: 'Payment',
      senderId: friendWalletId,
      receiverId: myWalletId,
    ),
  ];

  final myWallet = Wallet(
    $_id: myWalletId,
    transactions: myTransactions,
  );

  test('initial wallet balance', () {
    expect(myWallet.balance, 100.0);
  });

  test('wallet balance after I send 50 to friend', () {
    myWallet.transactions.add(
      Transaction(
        $_id: ObjectId(),
        amount: 50,
        date: DateTime.now().subtract(
          const Duration(hours: 23),
        ),
        description: 'Payment',
        senderId: myWalletId,
        receiverId: friendWalletId,
      ),
    );

    print('saint Points: ${myWallet.saintPoints}');
    expect(myWallet.balance, 50.0);
    expect(myWallet.saintPoints, 5);
  });

  test('wallet balance after I receive 25 from friend 5 times within 24 hours',
      () {
    for (var i = 0; i < 7; i++) {
      myWallet.transactions.add(
        Transaction(
          $_id: ObjectId(),
          amount: 25,
          date: DateTime.now().subtract(
            const Duration(hours: 23),
          ),
          description: 'Payment',
          senderId: friendWalletId,
          receiverId: myWalletId,
        ),
      );
    }

    expect(myWallet.balance, 225.0);
    expect(myWallet.saintPoints, 12);

    print('saint Points: ${myWallet.saintPoints}');

    final friendWallet = Wallet(
      $_id: friendWalletId,
      transactions: myTransactions,
    );

    print('====================');
    print('friend saint Points: ${friendWallet.saintPoints}');
    print('FriendTransactionsSent: ${friendWallet.transactionsSent.length}');
    print(
      'FriendTransactionsReceived: ${friendWallet.transactionsReceived.length}',
    );
  });
}
