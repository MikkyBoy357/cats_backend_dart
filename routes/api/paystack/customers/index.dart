import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  final request = context.request;
  final method = request.method;

  return switch (method) {
    HttpMethod.get => () async {
        final customers = await paystackClient.customers.all();
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
