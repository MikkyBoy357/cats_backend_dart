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

  PaymentTransaction({
    required this.gateway,
    required this.provider,
    required this.country,
    required this.tel,
    required this.amount,
    required this.description,
    required this.currency,
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
  }) {
    return PaymentTransaction(
      gateway: gateway ?? this.gateway,
      provider: provider ?? this.provider,
      country: country ?? this.country,
      tel: tel ?? this.tel,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      currency: currency ?? this.currency,
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
    );
  }
}

// gotten from the sckaler payment gateway /api/collection
class PaymentTransactionResponse {
  final String msg;
  final String status;
  final String transactionId;
  final PaymentTransaction? paymentTransactionBody;

  PaymentTransactionResponse({
    required this.msg,
    required this.status,
    required this.transactionId,
    required this.paymentTransactionBody,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'msg': msg,
      'status': status,
      'transaction_id': transactionId,
      if (paymentTransactionBody != null)
        'paymentTransactionBody': paymentTransactionBody!.toJson(),
    };
  }

  PaymentTransactionResponse copyWith({
    String? msg,
    String? status,
    String? transactionId,
    PaymentTransaction? paymentTransactionBody,
  }) {
    return PaymentTransactionResponse(
      msg: msg ?? this.msg,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      paymentTransactionBody:
          paymentTransactionBody ?? this.paymentTransactionBody,
    );
  }

  // sample data
  PaymentTransactionResponse sampleData() {
    return PaymentTransactionResponse(
      msg: 'SUCCESS',
      status: 'SUCCESS',
      transactionId: 'f4f15b3d-bc2c-4b0f-be75-8891dc5e47c8',
      paymentTransactionBody: PaymentTransaction.sampleData(),
    );
  }
}
