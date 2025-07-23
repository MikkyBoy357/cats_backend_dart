import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final userId = ObjectId.tryParse(id);
  if (userId == null) {
    return Response.json(
      body: 'Invalid User ID: $id',
      statusCode: 400,
    );
  }

  final request = context.request;
  final method = request.method;

  final ticketTypeRepository = TicketTypeRepository(
    database: await mongoDbPoolService.acquire(),
  );
  final eventRepository = EventRepository(
    database: await mongoDbPoolService.acquire(),
  );
  final handler = TicketTypeRequestHandlerImpl(
    ticketTypeRepository: ticketTypeRepository,
    eventRepository: eventRepository,
  );

  return switch (method) {
    HttpMethod.get => handler.handleGetTicketTypesForUser(
        userId: userId,
      ),
    _ => Future.value(
        Response(
          body: 'Unsupported request method: $method',
          statusCode: 405,
        ),
      ),
  };
}
