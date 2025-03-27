import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/helpers/helpers.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

Future<Response> onRequest(RequestContext context, String eventId) async {
  final hello = context.request.uri.pathSegments.last;
  printMagenta('Hello $hello');

  final id = ObjectId.tryParse(eventId);
  if (id == null) {
    return Response(
      body: 'Invalid event id: $eventId',
      statusCode: 400,
    );
  }

  final authValidationResponse = context.read<AuthValidationResponse>();
  final saint = authValidationResponse.user!;

  if (saint.userType != UserType.admin) {
    printGreen('user type===>${saint.userType}');
    return Response(
      body: 'Unauthorized: Admin access required',
      statusCode: 403,
    );
  }

  final eventRepository = EventRepository(database: mongoDbService.database);
  final ticketTypeRepository = TicketTypeRepository(
    database: mongoDbService.database,
  );
  final request = context.request;
  final method = request.method;
  final handler = EventRequestHandlerImpl(
    eventRepository: eventRepository,
    ticketTypeRepository: ticketTypeRepository,
  );

  return switch (method) {
    HttpMethod.get => () async {
        return handler.handleGetEventById(
          eventId: id,
          currentUser: saint,
        );
      }(),
    _ => Future.value(
        Response.json(
          body: 'Unsupported request method: $method',
          statusCode: 405,
        ),
      ),
  };
}
