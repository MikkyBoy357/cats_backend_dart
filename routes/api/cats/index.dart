import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/helpers/helpers.dart';
import 'package:cats_backend/services/mongo_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  final mongoService = await context.read<Future<MongoService>>();
  final authValidationResponse = context.read<AuthValidationResponse>();

  if (!authValidationResponse.isValid) {
    return Response.json(
      statusCode: 401,
      body: 'Auth Error: ${authValidationResponse.errorMessage}',
    );
  }

  final catRepository = CatRepository(database: mongoService.database);
  final request = context.request;
  final method = request.method;
  final queryParams = request.uri.queryParameters;
  final handler = CatRequestHandlerImpl();

  return switch (method) {
    HttpMethod.get => handler.handleGet(queryParams, catRepository),
    HttpMethod.post => handler.handlePost(request, catRepository),
    HttpMethod.put => handler.handlePut(queryParams, request, catRepository),
    HttpMethod.delete => handler.handleDelete(queryParams, catRepository),
    _ => Future.value(
        Response(body: 'Unsupported request method: $method', statusCode: 405),
      ),
  };
}
