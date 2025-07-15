import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/helpers/helpers.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String userId) async {
  final request = context.request;
  final method = request.method;

  final authValidationResponse = context.read<AuthValidationResponse>();
  final saint = authValidationResponse.user!;
  final eventRepository =
      EventRepository(database: await mongoDbPoolService.acquire());
  final ticketTypeRepository = TicketTypeRepository(
    database: await mongoDbPoolService.acquire(),
  );
  final handler = EventRequestHandlerImpl(
    eventRepository: eventRepository,
    ticketTypeRepository: ticketTypeRepository,
  );

  if (method != HttpMethod.get) {
    return Response(
      body: 'Unsupported request method: $method',
      statusCode: 405,
    );
  }

  final queryParams = request.uri.queryParameters;
  final searchTerm = queryParams['searchTerm'];
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

  final categoryIds = categoryList?.map((e) => toObjectId(e)).toList();
  final userObjectId = toObjectId(userId);

  return handler.handleGetUserEventsToday(
    userId: userObjectId,
    searchTerm: searchTerm,
    categoryIds: categoryIds,
    page: page,
    limit: limit,
  );
}
