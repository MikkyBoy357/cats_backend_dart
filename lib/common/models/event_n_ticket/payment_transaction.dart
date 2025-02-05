enum PaymentGateway {
  sckaler,
}

enum PaymentProvider {
  moov('Moov', 'moov'),
  mtn('MTN', 'mtn'),
  celtiis('Celtiis', 'celtiis');

  final String name;
  final String code;

  const PaymentProvider(this.name, this.code);
}

// ignore: constant_identifier_names
enum Country { BJ, CI, BF, CM, SN, ML }

// send to the sckaler payment gateway /api/collection (to collect payment)
class PaymentTransaction {
  PaymentGateway gateway;
  PaymentProvider provider;
  Country country;
  String tel;
  num amount;
  String description;
  String currency;
  DateTime createdAt;

  PaymentTransaction({
    required this.gateway,
    required this.provider,
    required this.country,
    required this.tel,
    required this.amount,
    required this.description,
    required this.currency,
    required this.createdAt,
  });

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      gateway: PaymentGateway.values.firstWhere(
        (e) => e.name == json['gateway'] as String,
      ),
      provider: PaymentProvider.values.firstWhere(
        (e) => e.code == json['provider'] as String,
      ),
      country: Country.values.firstWhere(
        (e) => e.name == json['country'] as String,
      ),
      tel: json['tel'] as String,
      amount: json['amount'] as num,
      description: json['description'] as String,
      currency: json['currency'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gateway': gateway.name,
      'provider': provider.code,
      'country': country.name,
      'tel': tel,
      'amount': amount,
      'description': description,
      'currency': currency,
      'createdAt': createdAt.toString(),
    };
  }

  PaymentTransaction copyWith({
    PaymentGateway? gateway,
    PaymentProvider? provider,
    Country? country,
    String? tel,
    num? amount,
    String? description,
    String? currency,
    DateTime? createdAt,
  }) {
    return PaymentTransaction(
      gateway: gateway ?? this.gateway,
      provider: provider ?? this.provider,
      country: country ?? this.country,
      tel: tel ?? this.tel,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory PaymentTransaction.sampleData() {
    return PaymentTransaction(
      gateway: PaymentGateway.sckaler,
      provider: PaymentProvider.mtn,
      country: Country.BJ,
      tel: '2290123456790',
      amount: 1000.0,
      description: 'Pool party ticket 1x',
      currency: 'XOF',
      createdAt: DateTime.now(),
    );
  }
}

// gotten from the sckaler payment gateway /api/collection
class PaymentTransactionResponse {
  final String msg;
  final String status;
  final String transactionId;
  final PaymentTransaction? paymentTransactionBody;
  final DateTime createdAt;

  PaymentTransactionResponse({
    required this.msg,
    required this.status,
    required this.transactionId,
    required this.paymentTransactionBody,
    required this.createdAt,
  });

  factory PaymentTransactionResponse.fromJson(Map<String, dynamic> json) {
    return PaymentTransactionResponse(
      msg: json['msg'] as String,
      status: json['status'] as String,
      transactionId: json['transaction_id'] as String,
      paymentTransactionBody: json['paymentTransactionBody'] != null
          ? PaymentTransaction.fromJson(
              json['paymentTransactionBody'] as Map<String, dynamic>,
            )
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'msg': msg,
      'status': status,
      'transaction_id': transactionId,
      if (paymentTransactionBody != null)
        'paymentTransactionBody': paymentTransactionBody!.toJson(),
      'createdAt': createdAt.toString(),
    };
  }

  PaymentTransactionResponse copyWith({
    String? msg,
    String? status,
    String? transactionId,
    PaymentTransaction? paymentTransactionBody,
    DateTime? createdAt,
  }) {
    return PaymentTransactionResponse(
      msg: msg ?? this.msg,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      paymentTransactionBody:
          paymentTransactionBody ?? this.paymentTransactionBody,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // sample data
  PaymentTransactionResponse sampleData() {
    return PaymentTransactionResponse(
      msg: 'SUCCESS',
      status: 'SUCCESS',
      transactionId: 'f4f15b3d-bc2c-4b0f-be75-8891dc5e47c8',
      paymentTransactionBody: PaymentTransaction.sampleData(),
      createdAt: DateTime.now(),
    );
  }
}
