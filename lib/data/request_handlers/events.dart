import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/data/repositories/repositories.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

abstract class EventRequestHandler {
  Future<Response> handleGetAllEvents();
  Future<Response> handleCreateEvent({required Event event});
  Future<Response> handleGetEventById({required ObjectId eventId});
  Future<Response> handleDeleteEvent({required ObjectId eventId});
}

class EventRequestHandlerImpl implements EventRequestHandler {
  final EventRepository _eventRepository;

  const EventRequestHandlerImpl({
    required EventRepository eventRepository,
  }) : _eventRepository = eventRepository;

  @override
  Future<Response> handleGetAllEvents() async {
    print('===> GET <==> Event:');
    final events = await _eventRepository.getEvents();

    return Response.json(
      body: events,
      statusCode: events.isNotEmpty ? 200 : 404,
    );
  }

  @override
  Future<Response> handleCreateEvent({required Event event}) async {
    print('===> POST <==> Event:');
    final createdEvent = await _eventRepository.createEvent(event: event);

    return Response.json(
      body: createdEvent,
      statusCode: createdEvent != null ? 201 : 400,
    );
  }

  @override
  Future<Response> handleGetEventById({required ObjectId eventId}) async {
    print('===> GET <==> Event:');
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
}
