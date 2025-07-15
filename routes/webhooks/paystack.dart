// lib/routes/webhooks/paystack.dart
import 'dart:io';

import 'package:cats_backend/common/common.dart';
import 'package:dart_frog/dart_frog.dart';

class PaystackWebhookBody {
  String? event;
  Map<String, dynamic> data;

  PaystackWebhookBody({
    this.event,
    required this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'event': event,
      'data': data,
    };
  }

  factory PaystackWebhookBody.fromJson(Map<String, dynamic> json) {
    return PaystackWebhookBody(
      event: json['event'] as String?,
      data: json['data'] as Map<String, dynamic>,
    );
  }
}

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.post) {
    printBlue('Paystack Webhook...');

    try {
      printMagenta('Processing Paystack Webhook...');
      print('Headers: ${await context.request.body()}');
      final requestJson = await context.request.json() as Map<String, dynamic>;

      final paystackWebhookBody = PaystackWebhookBody.fromJson(requestJson);
      final event = paystackWebhookBody.event;
      final data = paystackWebhookBody.data;

      // It's crucial to verify the signature (see step 3)
      // For now, let's just log the event
      print('Received Paystack Webhook Event: $event');
      print('Webhook Body: $requestJson');

      if (event == 'charge.success') {
        // Payment was successful!
        final transactionReference = data['reference'] as String;
        final amountPaid =
            (data['amount'] as int) / 100; // Paystack sends amount in kobo/cent
        final customer = data['customers'] as Map<String, dynamic>;
        final customerEmail = customer['email'] as String;

        print('Payment successful for reference: $transactionReference');
        print('Amount: NGN$amountPaid');
        print('Customer Email: $customerEmail');

        // TODO:
        // 1. Verify the transactions reference against your database to ensure
        // it's a valid, pending transactions.
        // 2. Issue the ticket to the user (update your database,
        // send email, etc.).
        // 3. Mark the transactions as completed in your database.

        return Response.json(
          body: {'message': 'Webhook received successfully'},
        );
      } else if (event == 'charge.failed') {
        // Payment failed
        print('Payment failed for reference: ${data['reference']}');
        // TODO: Handle failed payment (e.g., update transactions status in your DB, notify user)
        return Response.json(
          body: {'message': 'Webhook received successfully'},
        );
      }
      // Handle other events as needed (e.g., 'transfer.success', 'refund.successful')

      return Response.json(
        body: {'message': 'Event not handled'},
      );
    } catch (e) {
      print('Error processing webhook: $e');
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'message': 'Error processing webhook'},
      );
    }
  }
  return Response.json(
    statusCode: HttpStatus.methodNotAllowed,
    body: {'message': 'Method not allowed'},
  );
}
