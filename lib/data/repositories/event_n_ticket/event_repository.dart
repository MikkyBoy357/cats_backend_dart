import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/helpers/populate.dart';
import 'package:mongo_dart/mongo_dart.dart';

abstract class EventRepositoryImpl {
  Future<List<Event>> getEvents();
  Future<Event?> createEvent({required Event event});
  Future<Event?> getEventById({required ObjectId eventId});
  Future<bool> deleteEvent({required ObjectId eventId});
}

class EventRepository extends EventRepositoryImpl {
  final Db _database;

  EventRepository({
    required Db database,
  }) : _database = database;

  DbCollection get _eventsCollection => _database.eventsCollection;

  @override
  Future<List<Event>> getEvents() async {
    final eventsCollectionExt = DbCollectionExt(_eventsCollection);

    final res = await eventsCollectionExt.findAndPopulate(
      [
        PopulateField(fieldName: 'ticketType', collectionName: 'ticketTypes'),
      ],
    );
    printGreen('Events: $res');

    final events = res.map((e) => Event.fromJson(e)).toList();

    return events;
  }

  @override
  Future<Event?> createEvent({required Event event}) async {
    final result = await _eventsCollection.insertOne(event.toJson());
    print('Create Event result: $result');

    if (result.writeError != null) {
      return null;
    }

    return event;
  }

  @override
  Future<Event?> getEventById({required ObjectId eventId}) async {
    final result = await _eventsCollection.findOne({
      '_id': eventId,
    });

    if (result == null) {
      return null;
    }

    return Event.fromJson(result);
  }

  @override
  Future<bool> deleteEvent({required ObjectId eventId}) async {
    final result = await _eventsCollection.deleteOne({
      '_id': eventId,
    });

    if (result.writeError != null) {
      return false;
    }

    return true;
  }
}
