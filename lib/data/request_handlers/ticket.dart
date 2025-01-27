import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/data/data.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

abstract class TicketRequestHandler {
  Future<Response> handleGetAllTickets();
  Future<Response> handleGetTicketById({required ObjectId ticketId});
  Future<Response> handleCreateTicket({required TicketRequest ticketRequest});
  Future<Response> handleBuyTicket({
    required TicketBuyRequest ticketBuyRequest,
  });
}

class TicketRequestHandlerImpl implements TicketRequestHandler {
  final TicketRepository _ticketRepository;
  final EventRepository _eventRepository;
  final TicketTypeRepository _ticketTypeRepository;
  final SckalerRequestHandlerImpl _sckalerRequestHandler;

  const TicketRequestHandlerImpl({
    required TicketRepository ticketRepository,
    required EventRepository eventRepository,
    required TicketTypeRepository ticketTypeRepository,
    required SckalerRequestHandlerImpl sckalerRequestHandler,
  })  : _ticketRepository = ticketRepository,
        _eventRepository = eventRepository,
        _ticketTypeRepository = ticketTypeRepository,
        _sckalerRequestHandler = sckalerRequestHandler;

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
    );
  }

  @override
  Future<Response> handleCreateTicket({
    required TicketRequest ticketRequest,
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

  @override
  Future<Response> handleBuyTicket({
    required TicketBuyRequest ticketBuyRequest,
  }) async {
    print('===> POST <==> Buy Ticket:');

    final ticketType = await _ticketTypeRepository.getTicketTypeById(
      ticketTypeId: ticketBuyRequest.ticketRequest.ticketType,
    );
    printMagenta('TicketType found: ${ticketType?.toJson()}');
    if (ticketType == null) {
      return Response.json(
        body:
            'Ticket Type with ID `${ticketBuyRequest.ticketRequest.ticketType}` '
            'not found',
        statusCode: 404,
      );
    }

    final event = await _eventRepository.getEventById(
      eventId: ticketBuyRequest.ticketRequest.event,
    );
    printMagenta('Event found: ${event?.toJson()}');
    if (event == null) {
      return Response.json(
        body:
            'Event with ID `${ticketBuyRequest.ticketRequest.event}` not found',
        statusCode: 404,
      );
    }

    // first we collect payment
    ticketBuyRequest.paymentTransaction.amount = ticketType.price;
    ticketBuyRequest.paymentTransaction.description = 'Tické: '
        'PRICE: ${ticketType.price} Ë: ${event.name}';
    ticketBuyRequest.ticketRequest.issuedTo.phone =
        ticketBuyRequest.paymentTransaction.tel;
    // trim the description to 30 characters
    if (ticketBuyRequest.paymentTransaction.description.length > 30) {
      ticketBuyRequest.paymentTransaction.description =
          ticketBuyRequest.paymentTransaction.description.substring(0, 30);
    }

    final sckalerCollectionResponse =
        await _sckalerRequestHandler.handleSckalerCollection(
      paymentTransaction: ticketBuyRequest.paymentTransaction,
    );

    final sckalerCollectionResponseJson =
        await sckalerCollectionResponse.json();

    printMagenta(
      'Sckaler Collection Response: ${await sckalerCollectionResponse.json()}',
    );
    printBlue(
      'Sckaler Collection Status Code: ${sckalerCollectionResponse.statusCode}',
    );
    // if payment collection fails
    if (sckalerCollectionResponse.statusCode != 201) {
      printYellow(
        'Sckaler Collection Failure:',
      );
      return Response.json(
        body: sckalerCollectionResponseJson,
        statusCode: 400,
      );
    }

    // then we create ticket
    final ticketRequest = ticketBuyRequest.ticketRequest;
    final nextTicketNumber = await _ticketRepository.getNextTicketNumber(
      ticketType: ticketType,
    );

    final createTicketResponse = await handleCreateTicket(
      ticketRequest: ticketRequest.copyWith(
        ticketNumber: nextTicketNumber,
      ),
    );
    final createTicketResponseJson = await createTicketResponse.json();
    if (createTicketResponse.statusCode != 201) {
      printYellow(
        'Failed to create Ticket: $createTicketResponseJson',
      );
      return createTicketResponse;
    }
    return Response.json(
      body: {
        'message': 'Ticket purchased successfully',
        'ticket': createTicketResponseJson,
        'paymentInfo': sckalerCollectionResponseJson,
      },
      statusCode: 201,
    );
  }
}
