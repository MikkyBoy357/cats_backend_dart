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
      statusCode: events.isNotEmpty ? 200 : 404,
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
