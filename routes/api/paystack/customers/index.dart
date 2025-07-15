import 'package:dart_frog/dart_frog.dart';
import 'package:paystack/paystack.dart' hide HttpMethod, Response;

Future<Response> onRequest(RequestContext context) async {
  final request = context.request;
  final method = request.method;

  return switch (method) {
    HttpMethod.get => () async {
        final customers = await context.read<PaystackClient>().customers.all();
        return Response.json(
          body: {
            'status': customers.statusCode,
            'data': customers.data,
          },
        );
      }(),
    _ => Future.value(
        Response(
          body: 'Unsupported request method: $method',
          statusCode: 405,
        ),
      ),
  };
}
