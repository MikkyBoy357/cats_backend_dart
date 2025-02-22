import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/config/config.dart';
import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  // accept only POST requests

  final request = context.request;
  final method = request.method;

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
          return Response.json(
            body: 'Invalid JSON body',
            statusCode: 400,
          );
        }

        final keyWord = body['keyWord'];
        if (keyWord == null) {
          return Response.json(
            body: 'KeyWord is required',
            statusCode: 400,
          );
        }

        final decryptedKey = keyWord.toString().aes256Decrypt(Config.qrCodeKey);
        try {
          final ticketId = toObjectId(decryptedKey);
          return handler.handleGetTicketById(ticketId: ticketId);
        } catch (e) {
          return Response.json(
            body: 'Invalid ticket ID',
            statusCode: 400,
          );
        }
      }(),
    _ => Future.value(
        Response.json(
          body: 'Unsupported request method: $method',
          statusCode: 405,
        ),
      ),
  };
}
