import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

Future<Response> onRequest(RequestContext context) async {
  final request = context.request;
  final method = request.method;

  final eventCategoryRepository = EventCategoryRepository(
    database: mongoDbService.database,
  );

  final handler = EventCategoryRequestHandlerImpl(
    eventCategoryRepository: eventCategoryRepository,
  );

  return switch (method) {
    HttpMethod.get => handler.handleGetAllEventCategories(),
    HttpMethod.post => () async {
        final body = await request.tryJson;
        body?['_id'] = ObjectId();
        printMagenta(body.toString());
        if (body == null) {
          return Response.json(
            body: 'Invalid JSON body',
            statusCode: 400,
          );
        }

        final EventCategory eventCategory;

        try {
          eventCategory = EventCategory.fromJson(body);
        } catch (e) {
          printYellow(e.toString());
          return Response.json(body: 'Invalid EventCategory JSON body');
        }

        return handler.handleCreateEventCategory(
          eventCategory: eventCategory,
        );
      }(),
    _ => Future.value(
        Response(body: 'Unsupported request method: $method', statusCode: 405),
      ),
  };
}
