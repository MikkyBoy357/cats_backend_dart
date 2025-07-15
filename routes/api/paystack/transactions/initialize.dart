import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  final request = context.request;
  final method = request.method;

  return switch (method) {
    HttpMethod.post => () async {
        final body = await request.parseJson;

        final transactionBody = PaystackTransactionBody.fromJson(body);

        final initializeResponse = await paystackClient.transactions.initialize(
          transactionBody.amount, // Amount in kobo
          transactionBody.email,
        );

        return Response.json(
          body: {
            'status': initializeResponse.statusCode,
            'data': initializeResponse.data,
          },
        );
      }(),
    _ => Future.value(
        Response(body: 'Unsupported request method: $method', statusCode: 405),
      ),
  };
}

class PaystackTransactionBody {
  final String email;
  final int amount;
  final Map<String, dynamic>? metadata;

  PaystackTransactionBody({
    required this.email,
    required this.amount,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'amount': amount,
      'metadata': metadata,
    };
  }

  factory PaystackTransactionBody.fromJson(Map<String, dynamic> json) {
    return PaystackTransactionBody(
      email: json['email'] as String,
      amount: json['amount'] as int,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}
