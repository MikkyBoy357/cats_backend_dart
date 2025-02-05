import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/helpers/populate.dart';
import 'package:mongo_dart/mongo_dart.dart';

abstract class EventRepositoryImpl {
  Future<List<Event>> getEvents({List<ObjectId>? categoryIds});
  Future<Event?> createEvent({
    required EventRequest eventRequest,
    required List<String> mediaUrls,
  });
  Future<Event?> getEventById({required ObjectId eventId});
  Future<bool> deleteEvent({required ObjectId eventId});

  // Engagement tracking
  Future<bool> incrementViews({required ObjectId eventId});
  Future<bool> incrementClicks({required ObjectId eventId});
  Future<bool> incrementShares({required ObjectId eventId});
  Future<bool> incrementBookmarks({required ObjectId eventId});
  double calculateTrendScore(Event event);

  Future<List<Event>> getTrendingEvents();
}

class EventRepository extends EventRepositoryImpl {
  final Db _database;

  EventRepository({
    required Db database,
  }) : _database = database;

  DbCollection get _eventsCollection => _database.eventsCollection;

  final eventPopulateFields = [
    PopulateField(fieldName: 'ticketTypes', collectionName: 'ticketTypes'),
    PopulateField(fieldName: 'createdBy', collectionName: 'users'),
    PopulateField(
      fieldName: 'categories',
      collectionName: 'eventCategories',
    ),
  ];

  @override
  Future<List<Event>> getEvents({List<ObjectId>? categoryIds}) async {
    if (categoryIds != null && categoryIds.isNotEmpty) {
      // where at least one category matches
      final queryDocs = _eventsCollection
          .find(where.oneFrom('categories', categoryIds))
          .toList();

      final docs = await _eventsCollection.findAndPopulateLol(
        [
          // ...eventPopulateFields,
        ],
        queryDocs,
      );

      return docs.map((e) => Event.fromJson(e)).toList();
    }

    final res = await _eventsCollection.findAndPopulateRikky(
      [
        // ...eventPopulateFields,
      ],
    );

    final events = res.map((e) => Event.fromJson(e)).toList();
    return events;
  }

  @override
  Future<Event?> createEvent({
    required EventRequest eventRequest,
    required List<String> mediaUrls,
  }) async {
    final eventData = eventRequest.toJson();
    eventData['mediaUrls'] = mediaUrls;

    final result = await _eventsCollection.insertOne(eventData);
    if (result.writeError != null) {
      return null;
    }

    if (result.id is ObjectId) {
      final eventId = result.id as ObjectId;
      final event = await getEventById(eventId: eventId);
      return event;
    }

    return null;
  }

  @override
  Future<Event?> getEventById({required ObjectId eventId}) async {
    final result = await _eventsCollection.findOneAndPopulateRikky(
      {
        '_id': eventId,
      },
      fieldsToPopulate: [
        ...eventPopulateFields,
      ],
    );

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

  @override
  Future<bool> incrementViews({required ObjectId eventId}) async {
    final result = await _eventsCollection.updateOne(
      where.id(eventId),
      modify.inc('views', 1).set('lastUpdated', DateTime.now()),
    );

    final success = result.nModified > 0;
    return success;
  }

  @override
  Future<bool> incrementClicks({required ObjectId eventId}) async {
    final result = await _eventsCollection.updateOne(
      where.id(eventId),
      modify.inc('clicks', 1).set('lastUpdated', DateTime.now()),
    );

    final success = result.nModified > 0;
    return success;
  }

  @override
  Future<bool> incrementShares({required ObjectId eventId}) async {
    final result = await _eventsCollection.updateOne(
      where.id(eventId),
      modify.inc('shares', 1).set('lastUpdated', DateTime.now()),
    );

    final success = result.nModified > 0;
    return success;
  }

  @override
  Future<bool> incrementBookmarks({required ObjectId eventId}) async {
    final result = await _eventsCollection.updateOne(
      where.id(eventId),
      modify.inc('bookmarks', 1).set('lastUpdated', DateTime.now()),
    );

    final success = result.nModified > 0;
    return success;
  }

  @override
  double calculateTrendScore(Event event) {
    // Engagement weights
    const viewWeight = 0.3;
    const clickWeight = 0.5;
    const shareWeight = 0.8;
    const bookmarkWeight = 1.2;

    // Time decay factor (e.g., reduce score by 10% every hour)
    final hoursSinceLastUpdate =
        DateTime.now().difference(event.lastUpdated).inHours;
    final decayFactor = 1 / (1 + 0.1 * hoursSinceLastUpdate);

    // Calculate score
    final engagementScore = (event.views * viewWeight) +
        (event.clicks * clickWeight) +
        (event.shares * shareWeight) +
        (event.bookmarks * bookmarkWeight);

    return engagementScore * decayFactor;
  }

  @override
  Future<List<Event>> getTrendingEvents() async {
    final events = await getEvents();
    final trendingEvents = events
        .map(
          (e) => {
            'event': e,
            'trendScore': calculateTrendScore(e),
          },
        )
        .toList()
      ..sort(
        (a, b) => ((b['trendScore'] ?? '0') as double)
            .compareTo((a['trendScore'] ?? '0') as double),
      );

    return trendingEvents.map((e) => e['event']! as Event).toList();
  }
}
