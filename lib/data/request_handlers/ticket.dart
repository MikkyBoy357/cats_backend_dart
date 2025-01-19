import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/data/data.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

abstract class TicketRequestHandler {
  Future<Response> handleGetAllTickets();
  Future<Response> handleGetTicketById({required ObjectId ticketId});
  Future<Response> handleCreateTicket({
    required TicketRequest ticketRequest,
    required User saint,
  });
}

class TicketRequestHandlerImpl implements TicketRequestHandler {
  final TicketRepository _ticketRepository;
  final EventRepository _eventRepository;
  final TicketTypeRepository _ticketTypeRepository;

  const TicketRequestHandlerImpl({
    required TicketRepository ticketRepository,
    required EventRepository eventRepository,
    required TicketTypeRepository ticketTypeRepository,
  })  : _ticketRepository = ticketRepository,
        _eventRepository = eventRepository,
        _ticketTypeRepository = ticketTypeRepository;

  @override
  Future<Response> handleGetAllTickets() async {
    print('===> GET <==> Ticket:');
    final tickets = await _ticketRepository.getTickets();

    return Response.json(
      body: tickets,
      statusCode: tickets.isNotEmpty ? 200 : 404,
    );
  }

  @override
  Future<Response> handleGetTicketById({required ObjectId ticketId}) async {
    print('===> GET <==> Ticket:');
    final ticket = await _ticketRepository.getTicketById(
      ticketId: ticketId,
    );

    if (ticket == null) {
      return Response.json(
        body: 'Ticket with ID `$ticketId` not found',
        statusCode: 404,
      );
    }

    return Response.json(
      body: ticket,
      statusCode: 200,
    );
  }

  @override
  Future<Response> handleCreateTicket({
    required TicketRequest ticketRequest,
    required User saint,
  }) async {
    print('===> POST <==> Ticket:');

    final event = await _eventRepository.getEventById(
      eventId: ticketRequest.event,
    );

    printGreen('EVENT found: ${event?.toJson()}');

    if (event == null) {
      return Response.json(
        body: 'Event with ID `${ticketRequest.event}` not found',
        statusCode: 404,
      );
    }

    final ticketType = await _ticketTypeRepository.getTicketTypeById(
      ticketTypeId: ticketRequest.ticketType,
    );

    printGreen('TicketType found: ${ticketType?.toJson()}');

    if (ticketType == null) {
      return Response.json(
        body: 'Ticket Type with ID `${ticketRequest.ticketType}` not found',
        statusCode: 404,
      );
    }

    final nextTicketNumber = await _ticketRepository.getNextTicketNumber(
      ticketType: ticketType,
    );
    printGreen('Next Ticket Number: $nextTicketNumber');

    final createdTicket = await _ticketRepository.createTicket(
      ticketRequest: ticketRequest.copyWith(ticketNumber: nextTicketNumber),
    );

    if (createdTicket == null) {
      return Response.json(
        body: 'Failed to create ticket',
        statusCode: 500,
      );
    }

    return Response.json(
      body: createdTicket,
      statusCode: 201,
    );
  }
}
