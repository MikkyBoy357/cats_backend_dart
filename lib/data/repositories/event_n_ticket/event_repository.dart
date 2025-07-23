import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/helpers/helpers.dart';
import 'package:mongo_dart/mongo_dart.dart';

abstract class EventRepositoryImpl {
  Future<List<Event>> getEvents({
    List<ObjectId>? categoryIds,
    int page = 1,
    int limit = 20,
  });
  Future<List<Event>> getUserEvents({
    required ObjectId userId,
    String? searchTerm,
    List<ObjectId>? categoryIds,
    int page = 1,
    int limit = 20,
  });
  Future<Event?> createEvent({
    required EventRequest eventRequest,
    required List<String> mediaUrls,
  });
  Future<bool> addTicketTypeToEvent({
    required ObjectId eventId,
    required TicketType ticketType,
  });
  Future<Event?> getEventById({required ObjectId eventId});
  Future<bool> deleteEvent({required ObjectId eventId});

  // Engagement tracking
  Future<bool> incrementViews({required ObjectId eventId});
  Future<bool> incrementClicks({required ObjectId eventId});
  Future<bool> incrementShares({required ObjectId eventId});
  Future<bool> incrementBookmarks({required ObjectId eventId});
  double calculateTrendScore(Event event);
  Future<EventSales> calculateEventSales({required ObjectId eventId});

  Future<List<Event>> getTrendingEvents();
  Future<List<Event>> getUserEventsToday({
    required ObjectId userId,
    String? searchTerm,
    List<ObjectId>? categoryIds,
    int page = 1,
    int limit = 20,
  });
}

class EventRepository extends EventRepositoryImpl {
  final Db _database;

  EventRepository({
    required Db database,
  }) : _database = database;

  DbCollection get _eventsCollection => _database.eventsCollection;
  // final ticketRepository = TicketRepository(
  //   database:  mongoDbService.database,
  // );

  final eventPopulateFields = [
    PopulateField(fieldName: 'ticketTypes', collectionName: 'ticketTypes'),
    PopulateField(fieldName: 'createdBy', collectionName: 'users'),
    PopulateField(
      fieldName: 'categories',
      collectionName: 'eventCategories',
    ),
  ];

  @override
  Future<List<Event>> getEvents({
    List<ObjectId>? categoryIds,
    int page = 1,
    int limit = 20,
  }) async {
    final skip = (page - 1) * limit;

    if (categoryIds != null && categoryIds.isNotEmpty) {
      // where at least one category matches
      final queryDocs = _eventsCollection
          .find(
            where.oneFrom('categories', categoryIds).skip(skip).limit(limit),
          )
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
      limit: limit,
      page: page,
    );

    final events = res.map((e) => Event.fromJson(e)).toList();
    return events;
  }

  @override
  Future<List<Event>> getUserEvents({
    required ObjectId userId,
    String? searchTerm,
    List<ObjectId>? categoryIds,
    int page = 1,
    int limit = 20,
  }) async {
    final skip = (page - 1) * limit;

    var query = where.eq('createdBy', userId);

    if (searchTerm != null && searchTerm.isNotEmpty) {
      query = query.match('name', searchTerm, caseInsensitive: true);
    }

    if (categoryIds != null && categoryIds.isNotEmpty) {
      query = query.oneFrom('categories', categoryIds);
    }

    query = query.skip(skip).limit(limit);

    final docs = await _eventsCollection.find(query).toList();
    final events = docs.map((e) => Event.fromJson(e)).toList();

    final eventsWithSales = await Future.wait(
      events.map((event) async {
        final sales = await calculateEventSales(eventId: event.id);
        return event.copyWith(sales: sales);
      }),
    );

    return eventsWithSales;
  }

  @override
  Future<List<Event>> getUserEventsToday({
    required ObjectId userId,
    String? searchTerm,
    List<ObjectId>? categoryIds,
    int page = 1,
    int limit = 20,
  }) async {
    final skip = (page - 1) * limit;

    // Get today's date at beginning and end of day in UTC
    // This matches the format stored in your database: 2025-03-21T16:11:00.000Z
    final now = DateTime.now().toUtc();
    final todayStart = DateTime.utc(now.year, now.month, now.day);
    final todayEnd =
        DateTime.utc(now.year, now.month, now.day, 23, 59, 59, 999);

    printYellow(
      'Finding events between ${todayStart.toIso8601String()} '
      'and ${todayEnd.toIso8601String()}',
    );

    // Build the query
    // Note: Since date is stored as a string in ISO format, we need
    // to compare using string format
    var query = where
        .eq('createdBy', userId)
        .gte('date', todayStart.toIso8601String())
        .lte('date', todayEnd.toIso8601String());

    if (searchTerm != null && searchTerm.isNotEmpty) {
      query = query.match('name', searchTerm, caseInsensitive: true);
    }

    if (categoryIds != null && categoryIds.isNotEmpty) {
      query = query.oneFrom('categories', categoryIds);
    }

    query = query.skip(skip).limit(limit);

    final docs = await _eventsCollection.find(query).toList();
    final events = docs.map((e) => Event.fromJson(e)).toList();

    printYellow(
      'Found ${events.length} events happening today for user ${userId.oid}',
    );

    final eventsWithSales = await Future.wait(
      events.map((event) async {
        final sales = await calculateEventSales(eventId: event.id);
        return event.copyWith(sales: sales);
      }),
    );

    return eventsWithSales;
  }

  @override
  Future<EventSales> calculateEventSales({required ObjectId eventId}) async {
    final eventDoc = await _eventsCollection.findOneAndPopulateRikky(
      {'_id': eventId},
      fieldsToPopulate: [
        PopulateField(fieldName: 'ticketTypes', collectionName: 'ticketTypes'),
      ],
    );

    if (eventDoc == null) {
      return EventSales(
        ticketsSold: 0,
        ticketsScanned: 0,
        totalTicketSupply: 0,
      );
    }

    final event = Event.fromJson(eventDoc);

    final ticketAggregation =
        await _database.collection('tickets').aggregateToStream([
      {
        r'$match': {'event': eventId},
      },
      {
        r'$group': {
          '_id': r'$ticketType',
          'totalSold': {r'$sum': 1},
          'scanned': {
            r'$sum': {
              r'$cond': [r'$isScanned', 1, 0],
            },
          },
        },
      }
    ]).toList();

    final ticketTypes = event.ticketTypes
        .map(
          (ticketTypeEither) => ticketTypeEither.fold(
            (id) => null,
            (type) => type,
          ),
        )
        .where((type) => type != null)
        .toList();

    final ticketTypeSalesMap = <String, TicketTypeSales>{};
    var totalTicketSupply = 0;
    var totalTicketsSold = 0;
    var totalTicketsScanned = 0;

    final ticketTypeMap = {
      for (final type in ticketTypes.where((t) => t != null))
        type!.id.toString(): type,
    };

    for (final result in ticketAggregation) {
      final ticketTypeId = result['_id'] as ObjectId;
      final ticketTypeIdStr = ticketTypeId.toString();
      final ticketType = ticketTypeMap[ticketTypeIdStr];

      if (ticketType == null) continue;

      final sold = (result['totalSold'] as num).toInt();
      final scanned = (result['scanned'] as num).toInt();

      totalTicketsSold += sold;
      totalTicketsScanned += scanned;

      ticketTypeSalesMap[ticketTypeIdStr] = TicketTypeSales(
        ticketTypeId: ticketTypeId,
        name: ticketType.name,
        sold: sold,
        scanned: scanned,
        totalSupply: ticketType.totalSupply,
      );
    }

    for (final ticketType in ticketTypes) {
      if (ticketType == null) continue;

      final ticketTypeIdStr = ticketType.id.toString();
      totalTicketSupply += ticketType.totalSupply;

      if (!ticketTypeSalesMap.containsKey(ticketTypeIdStr)) {
        ticketTypeSalesMap[ticketTypeIdStr] = TicketTypeSales(
          ticketTypeId: ticketType.id,
          name: ticketType.name,
          sold: 0,
          scanned: 0,
          totalSupply: ticketType.totalSupply,
        );
      }
    }

    return EventSales(
      ticketsSold: totalTicketsSold,
      ticketsScanned: totalTicketsScanned,
      totalTicketSupply: totalTicketSupply,
      ticketTypeSales: ticketTypeSalesMap,
    );
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
  Future<bool> addTicketTypeToEvent({
    required ObjectId eventId,
    required TicketType ticketType,
  }) async {
    final result = await _eventsCollection.updateOne(
      where.id(eventId),
      modify.push('ticketTypes', ticketType.id).set(
            'lastUpdated',
            DateTime.now(),
          ),
    );

    if (result.writeError != null) {
      return false;
    }

    return true;
  }

  @override
  Future<Event?> getEventById({
    required ObjectId eventId,
    User? currentUser,
  }) async {
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

    final event = Event.fromJson(result);

    // Now the sales data will include per-ticket-type information
    if (currentUser != null && currentUser.userType == UserType.admin) {
      final sales = await calculateEventSales(eventId: eventId);
      return event.copyWith(sales: sales);
    }

    return event;
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
