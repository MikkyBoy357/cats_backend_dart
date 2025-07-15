import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final ticketId = ObjectId.tryParse(id);
  if (ticketId == null) {
    return Response(
      body: 'Invalid ticket id: $id',
      statusCode: 400,
    );
  }

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

  return switch (context.request.method) {
    HttpMethod.get => await handler.handleGetTicketById(
        ticketId: ticketId,
      ),
    _ => Response(
        body: 'Unsupported request method: ${context.request.method}',
        statusCode: 405,
      ),
  };
}
