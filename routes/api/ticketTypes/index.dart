import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  final request = context.request;
  final method = request.method;

  final ticketTypeRepository = TicketTypeRepository(
    database: await mongoDbPoolService.acquire(),
  );
  final handler = TicketTypeRequestHandlerImpl(
    ticketTypeRepository: ticketTypeRepository,
  );

  return switch (method) {
    HttpMethod.get => handler.handleGetAllTicketTypes(),
    _ => Future.value(
        Response(
          body: 'Unsupported request method: $method',
          statusCode: 405,
        ),
      ),
  };
}
