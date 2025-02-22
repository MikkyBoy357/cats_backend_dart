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

  final request = context.request;
  final method = request.method;

  final eventCategoryRepository = EventCategoryRepository(
    database: mongoDbService.database,
  );

  final handler = EventCategoryRequestHandlerImpl(
    eventCategoryRepository: eventCategoryRepository,
  );

  return switch (method) {
    HttpMethod.get => handler.handleGetEventCategoryById(
        eventCategoryId: eventId,
      ),
    HttpMethod.delete => handler.handleDeleteEventCategory(
        eventCategoryId: eventId,
      ),
    _ => Future.value(
        Response.json(
          body: 'Unsupported request method: $method',
          statusCode: 405,
        ),
      ),
  };
}
