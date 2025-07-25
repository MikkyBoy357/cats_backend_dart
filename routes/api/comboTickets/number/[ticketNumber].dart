import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/data/request_handlers/combo_ticket.dart';
import 'package:cats_backend/services/mongo_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String number) async {
  // percent sign is used to encode spaces in URLs, so we replace it with a space
  print('omo ->  $number');
  final ticketNumber = number.replaceAll('%20', ' ');
  print('omo ->  $ticketNumber');

  final comboTicketRepository = ComboTicketsRepository(
    database: await mongoDbPoolService.acquire(),
  );

  final comboTicketRequestHandler = ComboTicketRequestHandler(
    ticketRepository: comboTicketRepository,
  );

  return switch (context.request.method) {
    HttpMethod.get => await comboTicketRequestHandler.handleGetTicketByNumber(
        ticketNumber: ticketNumber,
      ),
    _ => Response(
        body: 'Unsupported request method: ${context.request.method}',
        statusCode: 405,
      ),
  };
}
