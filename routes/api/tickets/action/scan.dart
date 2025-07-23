import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/config/config.dart';
import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/helpers/helpers.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  // accept only POST requests
  final authValidationResponse = context.read<AuthValidationResponse>();

  if (!authValidationResponse.isValid) {
    return Response.json(
      statusCode: 401,
      body: 'Auth Error: ${authValidationResponse.errorMessage}',
    );
  }

  final saint = authValidationResponse.user!;
  printBlue('message--->${saint.$_id}');
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
        printMagenta('=========> Scan Request Started <=========');
        final body = await request.tryJson;
        if (body == null) {
          return Response.json(
            body: 'Invalid JSON body',
            statusCode: 400,
          );
        }
        final eventId = toObjectId(body['eventId']);
        // Check if we're scanning by ticket number or by ID (QR code)
        if (body.containsKey('ticketNumber')) {
          final ticketNumber = body['ticketNumber'] as String?;
          if (ticketNumber == null || ticketNumber.isEmpty) {
            return Response.json(
              body: 'Valid ticketNumber is required',
              statusCode: 400,
            );
          }

          // Get ticket by ticket number and then scan it
          return handler.handleScanTicketByNumber(
            ticketNumber: ticketNumber,
            userId: saint.$_id,
            eventId: eventId,
          );
        } else if (body.containsKey('keyWord')) {
          final keyWord = body['keyWord'];
          if (keyWord == null) {
            return Response.json(
              body: 'KeyWord is required',
              statusCode: 400,
            );
          }

          final decryptedKey =
              keyWord.toString().aes256Decrypt(Config.qrCodeKey);
          printBlue('omo -> $decryptedKey');

          try {
            final ticketId = toObjectId(decryptedKey);

            return handler.handleScanTicket(
              ticketId: ticketId,
              userId: saint.$_id,
              eventId: eventId,
            );
          } catch (e) {
            return Response.json(
              body: 'Invalid ticket ID',
              statusCode: 400,
            );
          }
        } else {
          return Response.json(
            body: 'Either ticketNumber or keyWord is required',
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
