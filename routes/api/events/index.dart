import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  final request = context.request;
  final method = request.method;
  final queryParams = request.uri.queryParameters;

  final eventRepository = EventRepository(database: mongoDbService.database);
  final handler = EventRequestHandlerImpl(eventRepository: eventRepository);

  return switch (method) {
    HttpMethod.get => handler.handleGetAllEvents(),
    _ => Future.value(
        Response(body: 'Unsupported request method: $method', statusCode: 405),
      ),
  };
}
