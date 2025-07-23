import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/helpers/helpers.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

Future<Response> onRequest(RequestContext context) async {
  final authValidationResponse = context.read<AuthValidationResponse>();

  if (!authValidationResponse.isValid) {
    return Response.json(
      statusCode: 401,
      body: 'Auth Error: ${authValidationResponse.errorMessage}',
    );
  }

  final ticketTypeRepository = TicketTypeRepository(
    database: await mongoDbPoolService.acquire(),
  );
  final eventRepository = EventRepository(
    database: await mongoDbPoolService.acquire(),
  );
  final request = context.request;
  final method = request.method;
  final handler = TicketTypeRequestHandlerImpl(
    ticketTypeRepository: ticketTypeRepository,
    eventRepository: eventRepository,
  );
  final saint = authValidationResponse.user!;

  return switch (method) {
    HttpMethod.post => () async {
        final body = await request.tryJson;
        if (body == null) {
          return Response.json(
            body: {'error': 'Invalid JSON body'},
            statusCode: 400,
          );
        }
        printBlue('body ===> $body');

        final requiredFields = ['price', 'name', 'description'];
        final missingFields =
            requiredFields.where((field) => body[field] == null).toList();

        if (missingFields.isNotEmpty) {
          return Response.json(
            body: {'error': 'Missing required fields: $missingFields'},
            statusCode: 400,
          );
        }

        final price = body['price'] as num;
        final name = body['name'] as String;
        final description = body['description'] as String;
        final totalSupply = body['totalSupply'] as int? ?? 69;
        final visibility = Visibility.values.firstWhere(
          (e) => e.name == body['visibility'],
          orElse: () => Visibility.public,
        );
        final codePrefix = body['codePrefix'] as String? ?? 'STR';
        final maxScansPerDay = body['maxScansPerDay'] as int?;
        final validFrom = body['validFrom'] != null
            ? DateTime.parse(body['validFrom'] as String)
            : null;
        final validUntil = body['validUntil'] != null
            ? DateTime.parse(body['validUntil'] as String)
            : null;

        final eventId = body['eventId'] as String?;

        printBlue('omo -> $maxScansPerDay');

        final ticketTypeRequest = TicketTypeRequest(
          price: price,
          name: name,
          description: description,
          totalSupply: totalSupply,
          visibility: visibility,
          codePrefix: codePrefix,
          createdBy: saint.$_id,
          validFrom: validFrom,
          validUntil: validUntil,
          maxScansPerDay: maxScansPerDay,
          eventId: eventId,
        );
        printBlue('omo -> ${ticketTypeRequest.validFrom}');

        final eventIdObject =
            ObjectId.tryParse(ticketTypeRequest.eventId ?? '');

        return handler.handleCreateTicketType(
          ticketType: ticketTypeRequest.toTicketType(),
          saint: saint,
          eventId: eventIdObject,
        );
      }(),
    _ => Future.value(
        Response.json(
          body: {'error': 'Invalid request method'},
          statusCode: 405,
        ),
      ),
  };
}
