import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/data/repositories/event_n_ticket/combo_tickets_repository.dart';
import 'package:cats_backend/helpers/helpers.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

abstract class ComboTicketRequestHandlerImpl {
  Future<Response> handleGetComboTickets();
  Future<Response> handleGetTicketById({
    required ObjectId ticketId,
    List<PopulateField>? fieldsToPopulate,
  });
  Future<Response> handleGetTicketByNumber({
    required String ticketNumber,
    List<PopulateField>? fieldsToPopulate,
  });
  Future<Response> handleScanComboTicket({
    required ObjectId eventId,
    required String ticketNumber,
  });
}

class ComboTicketRequestHandler extends ComboTicketRequestHandlerImpl {
  final ComboTicketsRepository _ticketRepository;

  ComboTicketRequestHandler({
    required ComboTicketsRepository ticketRepository,
  }) : _ticketRepository = ticketRepository;

  @override
  Future<Response> handleGetComboTickets() async {
    final tickets = await _ticketRepository.getComboTickets();
    return Response.json(
      body: tickets,
    );
  }

  @override
  Future<Response> handleGetTicketById({
    required ObjectId ticketId,
    List<PopulateField>? fieldsToPopulate,
  }) async {
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
    );
  }

  @override
  Future<Response> handleGetTicketByNumber({
    required String ticketNumber,
    List<PopulateField>? fieldsToPopulate,
  }) async {
    final ticket = await _ticketRepository.getTicketByComboCardNumber(
      comboCardNumber: ticketNumber,
    );

    if (ticket == null) {
      return Response.json(
        body: 'COMBO Ticket with NUMBER `$ticketNumber` not found',
        statusCode: 404,
      );
    }

    return Response.json(
      body: ticket,
    );
  }

  Future<List<Ticket>> handleGetTicketsByEventId({
    required ObjectId eventId,
  }) async {
    final tickets =
        await _ticketRepository.getTicketsByEventId(eventId: eventId);
    return tickets;
  }

  @override
  Future<Response> handleScanComboTicket({
    required ObjectId eventId,
    required String ticketNumber,
  }) async {
    final ticket = await _ticketRepository.getTicketByTicketNumber(
      ticketNumber: ticketNumber,
      populate: false,
    );

    if (ticket == null) {
      return Response.json(
        body: 'Ticket with number `$ticketNumber` not found',
        statusCode: 404,
      );
    }

    if (ticket.event.fold((id) => id, (event) => event.id) != eventId) {
      return Response.json(
        body: {
          'message': 'Ticket does not belong to this event',
        },
        statusCode: 404,
      );
    }

    final scannedTicket = await _ticketRepository.scanTicket(
      ticketId: ticket.id,
      scannedBy: ObjectId(),
    );

    if (scannedTicket == null) {
      return Response.json(
        body: 'Failed to scan ticket',
        statusCode: 500,
      );
    }

    return Response.json(
      body: scannedTicket,
    );
  }
}
