import 'package:cats_backend/common/common.dart';
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
    HttpMethod.post => () async {
        final body = await request.tryJson;
        if (body == null) {
          return Response.json(body: 'Invalid JSON body');
        }

        printYellow('Body: $body');
        final ticketBuyRequest = TicketBuyRequest.fromJson(body);

        return handler.handleBuyTicket(ticketBuyRequest: ticketBuyRequest);
      }(),
    _ => Future.value(Response.json(body: 'Invalid request method')),
  };
}
