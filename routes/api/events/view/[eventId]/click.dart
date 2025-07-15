import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  printYellow('hack the opps');
  final eventId = ObjectId.tryParse(id);

  if (eventId == null) {
    return Response(
      body: 'Invalid event id: $id',
      statusCode: 400,
    );
  }

  final request = context.request;
  final method = request.method;

  final eventRepository =
      EventRepository(database: await mongoDbPoolService.acquire());
  final ticketTypeRepository = TicketTypeRepository(
    database: await mongoDbPoolService.acquire(),
  );

  final handler = EventRequestHandlerImpl(
    eventRepository: eventRepository,
    ticketTypeRepository: ticketTypeRepository,
  );

  return switch (method) {
    HttpMethod.post => () async {
        return handler.handleIncrementClicks(
          eventId: eventId,
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
