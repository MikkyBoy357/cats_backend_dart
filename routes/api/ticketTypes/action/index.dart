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

  final ticketTypeRepository = TicketTypeRepository(
    database: mongoDbService.database,
  );
  final request = context.request;
  final method = request.method;
  final handler = TicketTypeRequestHandlerImpl(
    ticketTypeRepository: ticketTypeRepository,
  );

  return switch (method) {
    HttpMethod.post => () async {
        final body = await request.tryJson;
        if (body == null) {
          return Response.json(body: 'Invalid JSON body');
        }

        final ticketTypeRequest = TicketTypeRequest.fromJson(body);
        return handler.handleCreateTicketType(
          ticketType: ticketTypeRequest.toTicketType(),
        );
      }(),
    _ => Future.value(Response.json(body: 'Invalid request method')),
  };
}
