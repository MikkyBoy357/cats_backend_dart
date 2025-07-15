import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/helpers/helpers.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final authValidationResponse = context.read<AuthValidationResponse>();

  if (!authValidationResponse.isValid) {
    return Response.json(
      statusCode: 401,
      body: 'Auth Error: ${authValidationResponse.errorMessage}',
    );
  }

  // final saint = authValidationResponse.user!;

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

  final request = context.request;
  final method = request.method;
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
        try {
          final objectId = ObjectId.parse(id);
          return await handler.handleGetTicketsByTicketTypes(
            ticketTypeId: objectId,
          );
        } catch (e) {
          return Response.json(
            body: 'Invalid TicketType ID format',
            statusCode: 400,
          );
        }
      }(),
    _ => Future.value(Response.json(body: 'Invalid request method')),
  };
}
