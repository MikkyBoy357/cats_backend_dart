import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/data/repositories/repositories.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

abstract class EventCategoryRequestHandler {
  Future<Response> handleGetAllEventCategories();
  Future<Response> handleCreateEventCategory({
    required EventCategory eventCategory,
  });
  Future<Response> handleGetEventCategoryById({
    required ObjectId eventCategoryId,
  });
  Future<Response> handleDeleteEventCategory({
    required ObjectId eventCategoryId,
  });
}

class EventCategoryRequestHandlerImpl implements EventCategoryRequestHandler {
  final EventCategoryRepository _eventCategoryRepository;

  const EventCategoryRequestHandlerImpl({
    required EventCategoryRepository eventCategoryRepository,
  }) : _eventCategoryRepository = eventCategoryRepository;

  @override
  Future<Response> handleGetAllEventCategories() async {
    print('===> GET <==> Event Category:');
    final eventCategories = await _eventCategoryRepository.getEventCategories();

    return Response.json(
      body: eventCategories,
    );
  }

  @override
  Future<Response> handleCreateEventCategory({
    required EventCategory eventCategory,
  }) async {
    print('===> POST <==> Event Category:');
    final createdEventCategory =
        await _eventCategoryRepository.createEventCategory(
      eventCategoryRequest: eventCategory,
    );

    return Response.json(
      body: createdEventCategory,
      statusCode: 201,
    );
  }

  @override
  Future<Response> handleGetEventCategoryById({
    required ObjectId eventCategoryId,
  }) async {
    print('===> GET <==> Event Category:');
    final eventCategory = await _eventCategoryRepository.getEventCategoryById(
      eventCategoryId: eventCategoryId,
    );

    return Response.json(
      body: eventCategory,
      statusCode: eventCategory != null ? 200 : 404,
    );
  }

  @override
  Future<Response> handleDeleteEventCategory({
    required ObjectId eventCategoryId,
  }) async {
    print('===> DELETE <==> Event Category:');
    final deletedEventCategory =
        await _eventCategoryRepository.deleteEventCategory(
      eventCategoryId: eventCategoryId,
    );

    return Response.json(
      body: deletedEventCategory,
      statusCode: deletedEventCategory ? 200 : 404,
    );
  }
}
