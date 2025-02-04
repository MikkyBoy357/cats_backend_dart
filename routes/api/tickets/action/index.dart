import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/helpers/helpers.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  final authValidationResponse = context.read<AuthValidationResponse>();

  if (!authValidationResponse.isValid) {
    return Response.json(
      statusCode: 401,
      body: 'Auth Error: ${authValidationResponse.errorMessage}',
    );
  }

  final saint = authValidationResponse.user!;

  final ticketRepository = TicketRepository(
    database: mongoDbService.database,
  );

  final collectionRepository = SckalerCollectionRepository(
    database: mongoDbService.database,
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
    eventRepository: EventRepository(database: mongoDbService.database),
    ticketTypeRepository: TicketTypeRepository(
      database: mongoDbService.database,
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

        body['createdBy'] = saint.$_id.oid;

        final ticketRequest = TicketRequest.fromJson(body);
        printGreen('TicketType: ${ticketRequest.ticketType}');

        print('OMO: ${ticketRequest.toJson()}');

        return handler.handleCreateTicket(ticketRequest: ticketRequest);
      }(),
    _ => Future.value(Response.json(body: 'Invalid request method')),
  };
}
