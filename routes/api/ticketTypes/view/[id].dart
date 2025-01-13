import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final ticketTypeId = ObjectId.tryParse(id);
  if (ticketTypeId == null) {
    return Response.json(
      body: 'Invalid ticket type ID: $id',
      statusCode: 400,
    );
  }

  final request = context.request;
  final method = request.method;
  final queryParams = request.uri.queryParameters;

  final ticketTypeRepository = TicketTypeRepository(
    database: mongoDbService.database,
  );
  final handler = TicketTypeRequestHandlerImpl(
    ticketTypeRepository: ticketTypeRepository,
  );

  return switch (method) {
    HttpMethod.get => handler.handleGetTicketTypeById(
        ticketTypeId: ticketTypeId,
      ),
    _ => Future.value(
        Response(
          body: 'Unsupported request method: $method',
          statusCode: 405,
        ),
      ),
  };
}
