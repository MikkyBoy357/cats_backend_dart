import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  // Should make Auth not required for this endpoint
  //
  // final authValidationResponse = context.read<AuthValidationResponse>();
  //
  // final saint = authValidationResponse.user;

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
        final page = int.tryParse(queryParams['page'] ?? '1') ?? 1;
        final limit = int.tryParse(queryParams['limit'] ?? '10') ?? 10;

        final categoryList = categories
            ?.replaceAll('[', '')
            .replaceAll(']', '')
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        printBlue('Parsed category list: $categoryList');

        final categoryIds = categoryList?.map((e) => toObjectId(e)).toList();

        if (categoryIds != null && categoryIds.isNotEmpty) {
          printGreen('Category IDs: $categoryIds');
          return handler.handleGetAllEvents(
            categoryIds: categoryIds,
            page: page,
            limit: limit,
          );
        }

        return handler.handleGetAllEvents(
          page: page,
          limit: limit,
        );
      }(),
    _ => Future.value(
        Response(body: 'Unsupported request method: $method', statusCode: 405),
      ),
  };
}
