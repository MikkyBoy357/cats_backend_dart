import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  final request = context.request;
  final method = request.method;

  final ticketRepository = TicketRepository(
    database: await mongoDbPoolService.acquire(),
  );

  final collectionRepository = SckalerCollectionRepository(
    database: await mongoDbPoolService.acquire(),
  );
  final sckalerRequestHandler = SckalerRequestHandlerImpl(
    sckalerCollectionRepository: collectionRepository,
  );
  final mailRequestHandler = MailRequestHandler(
    mailRepository: MailRepository(),
  );

  final handler = TicketRequestHandlerImpl(
    ticketRepository: ticketRepository,
    eventRepository:
        EventRepository(database: await mongoDbPoolService.acquire()),
    ticketTypeRepository: TicketTypeRepository(
      database: await mongoDbPoolService.acquire(),
    ),
    sckalerRequestHandler: sckalerRequestHandler,
    mailRequestHandler: mailRequestHandler,
  );

  return switch (method) {
    HttpMethod.get => () async {
        final queryParams = request.uri.queryParameters;

        final ticketNumber = queryParams['ticketNumber'];
        final comboCardNumber = queryParams['comboCardNumber'];

        if (ticketNumber != null || comboCardNumber != null) {
          final query = <String, dynamic>{
            if (ticketNumber != null) 'ticketNumber': ticketNumber,
            if (comboCardNumber != null) 'comboCardNumber': comboCardNumber,
          };

          return handler.handleGetAllTicketsByQueries(
            queries: query,
          );
        }

        return handler.handleGetAllTickets();
      }(),
    _ => Future.value(
        Response(body: 'Unsupported request method: $method', statusCode: 405),
      ),
  };
}
