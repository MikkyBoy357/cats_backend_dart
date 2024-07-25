import 'package:cats_backend/common/models/transaction.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Streak {
  DateTime startDate;
  DateTime endDate;
  int transactionCount;
  double totalAmount;
  double averageAmount;
  List<double> amounts;

  Streak({
    required this.startDate,
    required this.endDate,
    required this.transactionCount,
    required this.totalAmount,
    required this.averageAmount,
    this.amounts = const [],
  });

  factory Streak.fromJson(Map<String, dynamic> map) {
    return Streak(
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      transactionCount: map['transactionCount'] as int,
      totalAmount: map['totalAmount'] as double,
      averageAmount: map['averageAmount'] as double,
      amounts: (map['amounts'] as List<dynamic>).cast<double>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'transactionCount': transactionCount,
      'totalAmount': totalAmount,
      'averageAmount': averageAmount,
      'amounts': amounts,
    };
  }
}

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

  List<Transaction> get transactionsSent {
    return transactions.where((e) => e.senderId == $_id).toList();
  }

  List<Transaction> get transactionsReceived {
    return transactions.where((e) => e.receiverId == $_id).toList();
  }

  List<Streak> getStreaks() {
    /// get streaks from transactions
    /// a streak is when a user has (5) consecutive
    /// transactionsSent within 24 hours
    ///
    /// keep track of the streaks data

    var streakStep = 0;
    final streaks = <Streak>[];
    var streakTransactions = <Transaction>[];
    final transactionsLengthIsGreaterThanFive = transactionsSent.length >= 5;

    print(transactionsSent.length);
    print(transactionsLengthIsGreaterThanFive);

    if (!transactionsLengthIsGreaterThanFive) {
      print('Not enough transactionsSent to form a streak');
      return streaks;
    }

    for (var i = 1; i < transactionsSent.length; i++) {
      final transaction = transactionsSent[i];
      final prevTransaction = transactionsSent[i - 1];

      if (transaction.date.difference(prevTransaction.date).inHours < 24) {
        streakStep++;
        streakTransactions.add(prevTransaction);

        print('streakStep: $streakStep');
        print('streakTransactionsCount: ${streakTransactions.length}');
        print('streakTransactions: $streakTransactions');
      } else {
        streakStep = 0;
        streakTransactions = [];
      }

      if (streakStep == 4) {
        streakTransactions.add(transaction);
        streaks.add(
          Streak(
            startDate: streakTransactions.first.date,
            endDate: streakTransactions.last.date,
            transactionCount: streakTransactions.length,
            totalAmount: streakTransactions.fold<double>(
              0,
              (previousValue, element) => previousValue + element.amount,
            ),
            averageAmount: streakTransactions.fold<double>(
                  0,
                  (previousValue, element) => previousValue + element.amount,
                ) /
                streakTransactions.length,
            amounts: streakTransactions
                .map((transaction) => transaction.amount)
                .toList(),
          ),
        );

        streakStep = 0;
        streakTransactions = [];
      }
    }

    print('Total transactionsSent: ${transactionsSent.length}');
    print('Total streaks: ${streaks.length}');
    print(
      'Total sent transactionsSent: ${transactionsSent.where((e) => e.receiverId == $_id).length}',
    );

    return streaks;
  }

  int get saintPoints {
    /// saintPoint is a score based on the
    /// wallet transaction frequency, streaks, and amount, etc.
    ///
    /// user gets 3 points for every transaction where user is sender
    /// user gets 1 point for every transaction where user is receiver
    ///
    /// user gets 5 points bonus for every 5 _transactionsSent in 24 hours
    ///
    /// these points are used to determine the user's rank
    /// user can be a saint, a sinner, or a neutral
    /// saint: user has more than 100 points
    /// sinner: user has less than -100 points
    /// neutral: user has between -100 and 100 points
    ///
    /// The saintPoints will later be used
    /// to unlock certain features and privileges
    ///
    /// Streak is when a user has consecutive
    /// _transactionsSent within 24 hours
    ///
    /// keep good track of the streaks data

    var points = 0;

    /// user gets 3 points for every transaction where user is sender
    for (final _ in transactionsSent) {
      points += 3;
    }

    /// user gets 1 point for every transaction where user is receiver
    for (final _ in transactionsReceived) {
      points += 1;
    }

    /// user gets 5 points bonus for every 5 _transactionsSent in 24 hours
    final streaks = getStreaks();
    for (final _ in streaks) {
      points += 5;
    }

    return points;
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
