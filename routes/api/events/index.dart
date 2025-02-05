import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  final request = context.request;
  final method = request.method;

  final eventRepository = EventRepository(database: mongoDbService.database);
  final ticketTypeRepository = TicketTypeRepository(
    database: mongoDbService.database,
  );
  final handler = EventRequestHandlerImpl(
    eventRepository: eventRepository,
    ticketTypeRepository: ticketTypeRepository,
  );

  return switch (method) {
    HttpMethod.get => () {
        final queryParams = request.uri.queryParameters;
        final categories = queryParams['categories'];

        final categoryList = categories
            ?.replaceAll('[', '')
            .replaceAll(']', '')
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        printBlue('Parsed category list: $categoryList');

        final categoryIds = categoryList?.map((e) => toObjectId(e)).toList();

        if (categoryIds!.isNotEmpty) {
          printGreen('Category IDs: $categoryIds');
          return handler.handleGetAllEvents(categoryIds: categoryIds);
        }

        return handler.handleGetAllEvents();
      }(),
    _ => Future.value(
        Response(body: 'Unsupported request method: $method', statusCode: 405),
      ),
  };
}
