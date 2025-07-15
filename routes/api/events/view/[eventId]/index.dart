import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

Future<Response> onRequest(RequestContext context, String eventId) async {
  final hello = context.request.uri.pathSegments.last;
  printMagenta('Hello $hello');

  final id = ObjectId.tryParse(eventId);
  if (id == null) {
    return Response(
      body: 'Invalid event id: $eventId',
      statusCode: 400,
    );
  }

  final eventRepository =
      EventRepository(database: await mongoDbPoolService.acquire());
  final ticketTypeRepository = TicketTypeRepository(
    database: await mongoDbPoolService.acquire(),
  );
  final request = context.request;
  final method = request.method;
  final handler = EventRequestHandlerImpl(
    eventRepository: eventRepository,
    ticketTypeRepository: ticketTypeRepository,
  );

  return switch (method) {
    HttpMethod.get => () async {
        return handler.handleGetEventById(
          eventId: id,
        );
      }(),
    _ => Future.value(
        Response.json(
          body: 'Unsupported request method: $method',
          statusCode: 405,
        ),
      ),
  };
}
