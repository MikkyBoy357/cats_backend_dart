import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/data/request_handlers/combo_ticket.dart';
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

  final comboTicketRepository = ComboTicketsRepository(
    database: await mongoDbPoolService.acquire(),
  );

  final comboTicketRequestHandler = ComboTicketRequestHandler(
    ticketRepository: comboTicketRepository,
  );

  return switch (context.request.method) {
    HttpMethod.post => () async {
        printMagenta('=========> Scan Request Started <=========');
        final body = await context.request.tryJson;
        if (body == null) {
          return Response.json(
            body: 'Invalid JSON body',
            statusCode: 400,
          );
        }
        final eventId = toObjectId(body['eventId']);
        // Check if we're scanning by ticket number or by ID (QR code)
        final ticketNumber = body['ticketNumber'] as String?;
        final ticketId = body['ticketId'] as String?;

        // if (ticketId == null) {
        //   return Response.json(
        //     body: 'Missing ticket ID',
        //     statusCode: 400,
        //   );
        // }

        if (ticketNumber != null) {
          return comboTicketRequestHandler.handleScanComboTicket(
            eventId: eventId,
            ticketNumber: ticketNumber,
          );
        } else {
          return Response.json(
            body: 'Missing ticket number or ID',
            statusCode: 400,
          );
        }
      }(),
    _ => Future.value(
        Response(body: 'Unsupported request method', statusCode: 405),
      ),
  };
}
