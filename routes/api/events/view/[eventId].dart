import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final eventId = ObjectId.tryParse(id);
  if (eventId == null) {
    return Response(
      body: 'Invalid event id: $id',
      statusCode: 400,
    );
  }

  final eventRepository = EventRepository(database: mongoDbService.database);
  final request = context.request;
  final method = request.method;
  final handler = EventRequestHandlerImpl(eventRepository: eventRepository);

  return switch (method) {
    HttpMethod.get => await handler.handleGetEventById(
        eventId: eventId,
      ),
    _ => Response(
        body: 'Unsupported request method: $method',
        statusCode: 405,
      ),
  };
}
