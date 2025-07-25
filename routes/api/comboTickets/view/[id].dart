import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/data/request_handlers/combo_ticket.dart';
import 'package:cats_backend/services/mongo_service.dart';
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

  final comboTicketRepository = ComboTicketsRepository(
    database: await mongoDbPoolService.acquire(),
  );

  final comboTicketRequestHandler = ComboTicketRequestHandler(
    ticketRepository: comboTicketRepository,
  );

  return switch (context.request.method) {
    HttpMethod.get => await comboTicketRequestHandler.handleGetTicketById(
        ticketId: ticketId,
      ),
    _ => Response(
        body: 'Unsupported request method: ${context.request.method}',
        statusCode: 405,
      ),
  };
}
