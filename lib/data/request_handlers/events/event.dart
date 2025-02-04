import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/data/repositories/repositories.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

abstract class EventRequestHandler {
  Future<Response> handleGetAllEvents();
  Future<Response> handleCreateEvent({
    required EventRequest eventRequest,
    required User saint,
  });
  Future<Response> handleGetEventById({required ObjectId eventId});
  Future<Response> handleDeleteEvent({required ObjectId eventId});

  Future<Response> handleGetFeed();
  Future<Response> handleGetTrendingEvents();
  Future<Response> handleGetNearbyEvents();

  // Engagement
  Future<Response> handleIncrementViews({required ObjectId eventId});
  Future<Response> handleIncrementClicks({required ObjectId eventId});
  Future<Response> handleIncrementShares({required ObjectId eventId});
  Future<Response> handleIncrementBookmarks({required ObjectId eventId});
}

class EventRequestHandlerImpl implements EventRequestHandler {
  final EventRepository _eventRepository;
  final TicketTypeRepository _ticketTypeRepository;

  const EventRequestHandlerImpl({
    required EventRepository eventRepository,
    required TicketTypeRepository ticketTypeRepository,
  })  : _eventRepository = eventRepository,
        _ticketTypeRepository = ticketTypeRepository;

  @override
  Future<Response> handleGetAllEvents() async {
    print('===> GET <==> Event:');
    final events = await _eventRepository.getEvents();

    return Response.json(
      body: events,
    );
  }

  @override
  Future<Response> handleCreateEvent({
    required EventRequest eventRequest,
    required User saint,
  }) async {
    print('===> POST <==> Event:');
    final ticketType = await _ticketTypeRepository.getTicketTypeById(
      ticketTypeId: eventRequest.ticketType,
    );

    if (ticketType == null) {
      return Response.json(
        body: 'Ticket Type with ID `${eventRequest.ticketType}` not found',
        statusCode: 404,
      );
    }

    final createdEvent = await _eventRepository.createEvent(
      eventRequest: eventRequest,
    );

    if (createdEvent == null) {
      return Response.json(
        body: 'Failed to create event',
        statusCode: 400,
      );
    }

    return Response.json(
      body: createdEvent,
      statusCode: 201,
    );
  }

  @override
  Future<Response> handleGetEventById({required ObjectId eventId}) async {
    print('===> GET <==> Event:');

    // Track event view
    await _eventRepository.incrementViews(eventId: eventId);

    final event = await _eventRepository.getEventById(eventId: eventId);

    return Response.json(
      body: event,
      statusCode: event != null ? 200 : 404,
    );
  }

  @override
  Future<Response> handleDeleteEvent({required ObjectId eventId}) async {
    print('===> DELETE <==> Event:');
    final isDeleted = await _eventRepository.deleteEvent(eventId: eventId);

    return Response.json(
      body: isDeleted,
      statusCode: isDeleted ? 200 : 404,
    );
  }

  @override
  Future<Response> handleGetFeed() async {
    // Step 1: Get trending events (top 10)
    final trendingEvents = await _eventRepository.getTrendingEvents();

    // Step 2: Define nearby events (same as trending for now)
    final nearbyEvents = trendingEvents.sublist(0, 10);

    // Step 3: Take top 10 trending events
    final trending = trendingEvents.sublist(0, 10);

    // Step 4: Get all events from repository
    final allEvents = trendingEvents;

    // Step 5: Separate non-trending events from trending ones
    final nonTrendingEvents =
        allEvents.where((event) => !trending.contains(event)).toList();

    // Step 6: Shuffle top 5 non-trending events to give them more visibility
    if (nonTrendingEvents.length > 5) {
      final top5Feed = nonTrendingEvents.sublist(0, 5)..shuffle();
      nonTrendingEvents.replaceRange(0, 5, top5Feed);
    }

    // Step 7: Combine non-trending and trending events in the feed
    final feedEvents = [...nonTrendingEvents, ...trending];

    printMagenta('Trending: ${trending.length}');
    printMagenta('Nearby: ${nearbyEvents.length}');
    printMagenta('Feed: ${feedEvents.length}');

    // Step 8: Return a response with the trending, nearby, and feed events
    return Response.json(
      body: {
        'trending': trending.map((e) => e.toJson()).toList(),
        'nearby': nearbyEvents.map((e) => e.toJson()).toList(),
        'feed': feedEvents.map((e) => e.toJson()).toList(),
      },
    );
  }

  @override
  Future<Response> handleGetTrendingEvents() async {
    print('===> GET <==> Event:');
    final events = await _eventRepository.getTrendingEvents();

    return Response.json(
      body: events,
    );
  }

  @override
  Future<Response> handleGetNearbyEvents() async {
    print('===> GET <==> Event:');
    final events = await _eventRepository.getTrendingEvents();

    return Response.json(
      body: events,
    );
  }

  @override
  Future<Response> handleIncrementViews({required ObjectId eventId}) async {
    final isIncremented = await _eventRepository.incrementViews(
      eventId: eventId,
    );

    return Response.json(
      body: {
        'incremented': isIncremented,
      },
      statusCode: isIncremented ? 200 : 404,
    );
  }

  @override
  Future<Response> handleIncrementClicks({required ObjectId eventId}) async {
    final isIncremented = await _eventRepository.incrementClicks(
      eventId: eventId,
    );

    return Response.json(
      body: {
        'incremented': isIncremented,
      },
      statusCode: isIncremented ? 200 : 404,
    );
  }

  @override
  Future<Response> handleIncrementShares({required ObjectId eventId}) async {
    final isIncremented = await _eventRepository.incrementShares(
      eventId: eventId,
    );

    return Response.json(
      body: {
        'incremented': isIncremented,
      },
      statusCode: isIncremented ? 200 : 404,
    );
  }

  @override
  Future<Response> handleIncrementBookmarks({required ObjectId eventId}) async {
    final isIncremented = await _eventRepository.incrementBookmarks(
      eventId: eventId,
    );

    return Response.json(
      body: {
        'incremented': isIncremented,
      },
      statusCode: isIncremented ? 200 : 404,
    );
  }
}
