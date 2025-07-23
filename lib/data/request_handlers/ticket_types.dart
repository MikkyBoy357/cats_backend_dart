import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/data/data.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

abstract class TicketTypeRequestHandler {
  Future<Response> handleGetAllTicketTypes();
  Future<Response> handleCreateTicketType({
    required TicketType ticketType,
    required User saint,
  });
  Future<Response> handleGetTicketTypeById({required ObjectId ticketTypeId});
  Future<Response> handleDeleteTicketType({required ObjectId ticketTypeId});
  Future<Response> handleGetTicketTypesForUser({required ObjectId userId});
}

class TicketTypeRequestHandlerImpl implements TicketTypeRequestHandler {
  final TicketTypeRepository _ticketTypeRepository;
  final EventRepository _eventRepository;

  const TicketTypeRequestHandlerImpl({
    required TicketTypeRepository ticketTypeRepository,
    required EventRepository eventRepository,
  })  : _ticketTypeRepository = ticketTypeRepository,
        _eventRepository = eventRepository;

  @override
  Future<Response> handleGetAllTicketTypes() async {
    final ticketTypes = await _ticketTypeRepository.getTicketTypes();

    return Response.json(
      body: ticketTypes,
    );
  }

  @override
  Future<Response> handleCreateTicketType({
    required TicketType ticketType,
    required User saint,
    ObjectId? eventId,
  }) async {
    final finalTicketType = ticketType.copyWith(createdBy: saint.$_id);
    final createdTicketType = await _ticketTypeRepository.createTicketType(
      ticketType: finalTicketType,
    );
    printBlue('lol -> ${finalTicketType.validUntil}');

    if (createdTicketType != null && eventId != null) {
      // add ticket type to event
      final updateEvent = await _eventRepository.addTicketTypeToEvent(
        eventId: eventId,
        ticketType: createdTicketType,
      );

      if (!updateEvent) {
        Response.json(
          body: {
            'message': 'Ticket type created but failed to add to event',
            'ticketType': createdTicketType.toJson(),
          },
          statusCode: 201,
        );
      }
    }

    return Response.json(
      body: createdTicketType?.toJson(),
      statusCode: createdTicketType != null ? 201 : 400,
    );
  }

  @override
  Future<Response> handleGetTicketTypesForUser({
    required ObjectId userId,
  }) async {
    final ticketTypes = await _ticketTypeRepository.getTicketTypesForUser(
      userId: userId,
    );

    return Response.json(
      body: ticketTypes,
      statusCode: ticketTypes.isNotEmpty ? 200 : 404,
    );
  }

  @override
  Future<Response> handleGetTicketTypeById({
    required ObjectId ticketTypeId,
  }) async {
    final ticketType = await _ticketTypeRepository.getTicketTypeById(
      ticketTypeId: ticketTypeId,
    );

    return Response.json(
      body: ticketType,
      statusCode: ticketType != null ? 200 : 404,
    );
  }

  @override
  Future<Response> handleDeleteTicketType({
    required ObjectId ticketTypeId,
  }) async {
    final isDeleted = await _ticketTypeRepository.deleteTicketType(
      ticketTypeId: ticketTypeId,
    );

    return Response.json(
      body: isDeleted,
      statusCode: isDeleted ? 200 : 404,
    );
  }
}
