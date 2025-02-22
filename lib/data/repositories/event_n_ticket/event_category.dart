import 'package:cats_backend/common/common.dart';
import 'package:mongo_dart/mongo_dart.dart';

abstract class EventCategoryRepositoryImpl {
  Future<List<EventCategory>> getEventCategories();
  Future<EventCategory?> createEventCategory({
    required EventCategory eventCategoryRequest,
  });
  Future<EventCategory?> getEventCategoryById({
    required ObjectId eventCategoryId,
  });
  Future<bool> deleteEventCategory({
    required ObjectId eventCategoryId,
  });
}

class EventCategoryRepository extends EventCategoryRepositoryImpl {
  final Db _database;

  EventCategoryRepository({
    required Db database,
  }) : _database = database;

  DbCollection get _eventCategoriesCollection =>
      _database.eventCategoriesCollection;

  @override
  Future<List<EventCategory>> getEventCategories() async {
    final res = await _eventCategoriesCollection.find().toList();
    printGreen('Event Categories: $res');

    final eventCategories = res.map((e) => EventCategory.fromJson(e)).toList();

    return eventCategories;
  }

  @override
  Future<EventCategory?> createEventCategory({
    required EventCategory eventCategoryRequest,
  }) async {
    final result = await _eventCategoriesCollection.insertOne(
      eventCategoryRequest.toJson(),
    );

    if (result.writeError != null) {
      return null;
    }

    if (result.id is ObjectId) {
      final eventCategoryId = result.id as ObjectId;
      final eventCategory = await getEventCategoryById(
        eventCategoryId: eventCategoryId,
      );
      return eventCategory;
    }

    return null;
  }

  @override
  Future<EventCategory?> getEventCategoryById({
    required ObjectId eventCategoryId,
  }) async {
    final result = await _eventCategoriesCollection.findOne(
      where.eq('_id', eventCategoryId),
    );

    if (result == null) {
      return null;
    }

    return EventCategory.fromJson(result);
  }

  @override
  Future<bool> deleteEventCategory({
    required ObjectId eventCategoryId,
  }) async {
    final result = await _eventCategoriesCollection.deleteOne(
      where.eq('_id', eventCategoryId),
    );

    final success = !result.isFailure;

    return success;
  }
}
