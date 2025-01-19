import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  final request = context.request;
  final method = request.method;

  final ticketRepository = TicketRepository(
    database: mongoDbService.database,
  );

  final handler = TicketRequestHandlerImpl(
    ticketRepository: ticketRepository,
    eventRepository: EventRepository(database: mongoDbService.database),
    ticketTypeRepository: TicketTypeRepository(
      database: mongoDbService.database,
    ),
  );

  return switch (method) {
    HttpMethod.get => handler.handleGetAllTickets(),
    _ => Future.value(
        Response(body: 'Unsupported request method: $method', statusCode: 405),
      ),
  };
}
