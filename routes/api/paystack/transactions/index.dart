import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  final request = context.request;
  final method = request.method;

  return switch (method) {
    HttpMethod.get => () async {
        final transactions = await paystackClient.transactions.all();
        return Response.json(
          body: {
            'status': transactions.statusCode,
            'data': transactions.data,
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
