import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  final request = context.request;
  final method = request.method;

  final collectionRepository = SckalerCollectionRepository(
    database: await mongoDbPoolService.acquire(),
  );
  final handler = SckalerRequestHandlerImpl(
    sckalerCollectionRepository: collectionRepository,
  );

  return switch (method) {
    HttpMethod.get => handler.handleGetSckalerCollections(),
    HttpMethod.post => () async {
        final body = await request.tryJson;
        if (body == null) {
          return Response.json(body: 'Invalid JSON body');
        }

        final PaymentTransaction paymentTransaction;

        try {
          paymentTransaction = PaymentTransaction.fromJson(body);
        } catch (e) {
          return Response.json(body: 'Invalid PaymentTransaction JSON body');
        }

        return handler.handleSckalerCollection(
          paymentTransaction: paymentTransaction,
        );
      }(),
    _ => Future.value(
        Response(body: 'Unsupported request method: $method', statusCode: 405),
      ),
  };
}
