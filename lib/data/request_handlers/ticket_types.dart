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
}

class TicketTypeRequestHandlerImpl implements TicketTypeRequestHandler {
  final TicketTypeRepository _ticketTypeRepository;

  const TicketTypeRequestHandlerImpl({
    required TicketTypeRepository ticketTypeRepository,
  }) : _ticketTypeRepository = ticketTypeRepository;

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
  }) async {
    final finalTicketType = ticketType.copyWith(createdBy: saint.$_id);
    final createdTicketType = await _ticketTypeRepository.createTicketType(
      ticketType: finalTicketType,
    );

    return Response.json(
      body: createdTicketType,
      statusCode: createdTicketType != null ? 201 : 400,
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
