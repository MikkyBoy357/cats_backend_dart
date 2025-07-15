import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/helpers/helpers.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

abstract class TicketRequestHandler {
  Future<Response> handleGetAllTickets();
  Future<Response> handleGetTicketById({required ObjectId ticketId});
  Future<Response> handleCreateTicket({required TicketRequest ticketRequest});
  Future<Response> handleBuyTicket({
    required TicketBuyRequest ticketBuyRequest,
  });
  Future<Response> handleGetTicketsByEventId({required ObjectId eventId});
  Future<Response> handleScanTicket({
    required ObjectId ticketId,
    required ObjectId userId,
    required ObjectId eventId,
  });
  Future<bool> checkTicketTypeSoldOut({required ObjectId ticketTypeId});
  Future<Response> handleGetTicketsByTicketTypes({
    required ObjectId ticketTypeId,
  });
  Future<Response> handleScanTicketByNumber({
    required String ticketNumber,
    required ObjectId userId,
    required ObjectId eventId,
  });
}

class TicketRequestHandlerImpl implements TicketRequestHandler {
  final TicketRepository _ticketRepository;
  final EventRepository _eventRepository;
  final TicketTypeRepository _ticketTypeRepository;
  final SckalerRequestHandlerImpl _sckalerRequestHandler;
  final MailRequestHandler _mailRequestHandler;

  const TicketRequestHandlerImpl({
    required TicketRepository ticketRepository,
    required EventRepository eventRepository,
    required TicketTypeRepository ticketTypeRepository,
    required SckalerRequestHandlerImpl sckalerRequestHandler,
    required MailRequestHandler mailRequestHandler,
  })  : _ticketRepository = ticketRepository,
        _eventRepository = eventRepository,
        _ticketTypeRepository = ticketTypeRepository,
        _sckalerRequestHandler = sckalerRequestHandler,
        _mailRequestHandler = mailRequestHandler;

  @override
  Future<Response> handleGetAllTickets() async {
    final tickets = await _ticketRepository.getTickets();

    return Response.json(
      body: tickets,
    );
  }

  @override
  Future<Response> handleGetTicketsByEventId(
      {required ObjectId eventId}) async {
    final event = await _eventRepository.getEventById(
      eventId: eventId,
    );

    if (event == null) {
      return Response.json(
        body: 'Event with ID `$eventId` not found',
        statusCode: 404,
      );
    }

    final tickets = await _ticketRepository.getTicketsByEventId(
      eventId: eventId,
    );

    return Response.json(
      body: tickets,
    );
  }

  @override
  Future<Response> handleGetTicketsByTicketTypes({
    required ObjectId ticketTypeId,
  }) async {
    final ticketType = await _ticketTypeRepository.getTicketTypeById(
      ticketTypeId: ticketTypeId,
    );

    if (ticketType == null) {
      return Response.json(
        body: 'TicketType with ID `$ticketTypeId` not found',
        statusCode: 404,
      );
    }

    final tickets = await _ticketRepository.getTicketsByTicketType(
      ticketTypeId: ticketTypeId,
    );

    return Response.json(
      body: tickets,
    );
  }

  @override
  Future<Response> handleScanTicketByNumber({
    required String ticketNumber,
    required ObjectId userId,
    required ObjectId eventId,
  }) async {
    final ticket = await _ticketRepository.getTicketByTicketNumber(
      ticketNumber: ticketNumber,
    );

    if (ticket == null) {
      return Response.json(
        body: {
          'message': 'Ticket with number `$ticketNumber` not found',
        },
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
    if (ticket.isScanned) {
      return Response.json(
        body: {
          'message': 'Ticket has already been scanned',
          'ticket': ticket,
        },
        statusCode: 400,
      );
    }

    final updatedTicket = await _ticketRepository.scanTicket(
      ticketId: ticket.id,
      scannedBy: userId,
    );

    if (updatedTicket == null) {
      return Response.json(
        body: {
          'message': 'Failed to Scan Ticket',
        },
        statusCode: 500,
      );
    }

    return Response.json(
      body: {
        'message': 'Ticket scanned successfully',
        'ticket': updatedTicket,
      },
    );
  }

  @override
  Future<Response> handleGetTicketById({required ObjectId ticketId}) async {
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
  Future<bool> checkTicketTypeSoldOut({required ObjectId ticketTypeId}) async {
    final ticketType = await _ticketTypeRepository.getTicketTypeById(
      ticketTypeId: ticketTypeId,
    );

    if (ticketType == null) {
      return true;
    }

    final issuedTickets = await _ticketRepository.getTicketsByTicketType(
      ticketTypeId: ticketTypeId,
    );

    if (ticketType.totalSupply == 0) {
      return false;
    }

    return issuedTickets.length >= ticketType.totalSupply;
  }

  @override
  Future<Response> handleCreateTicket({
    required TicketRequest ticketRequest,
  }) async {
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
    if (ticketType.soldOut) {
      return Response.json(
        body: {'message': 'This ticket type is sold out', 'soldOut': true},
        statusCode: 400,
      );
    }

    final isSoldOut = await checkTicketTypeSoldOut(
      ticketTypeId: ticketRequest.ticketType,
    );

    if (isSoldOut) {
      return Response.json(
        body: {'message': 'This ticket type is sold out', 'soldOut': true},
        statusCode: 400,
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
  Future<Response> handleScanTicket({
    required ObjectId ticketId,
    required ObjectId userId,
    required ObjectId eventId,
  }) async {
    final ticket = await _ticketRepository.getTicketById(ticketId: ticketId);

    if (ticket == null) {
      return Response.json(
        body: 'Ticket with ID `$ticketId` not found',
        statusCode: 404,
      );
    }
    if (ticket.event.fold((id) => id, (event) => event.id) != eventId) {
      return Response.json(
        body: 'Ticket does not belong to this event',
        statusCode: 404,
      );
    }

    if (ticket.isScanned) {
      return Response.json(
        body: {
          'message': 'Ticket has already been scanned',
          'ticket': ticket,
        },
        statusCode: 403,
      );
    }

    final updatedTicket = await _ticketRepository.scanTicket(
      ticketId: ticketId,
      scannedBy: userId,
    );

    if (updatedTicket == null) {
      return Response.json(
        body: 'Failed to scan ticket',
        statusCode: 500,
      );
    }

    return Response.json(
      body: {
        'message': 'Ticket scanned successfully',
        'ticket': updatedTicket,
      },
    );
  }

  @override
  Future<Response> handleBuyTicket({
    required TicketBuyRequest ticketBuyRequest,
  }) async {
    final ticketType = await _ticketTypeRepository.getTicketTypeById(
      ticketTypeId: ticketBuyRequest.ticketRequest.ticketType,
    );
    printMagenta('TicketType found: ${ticketType?.toJson()}');
    if (ticketType == null) {
      return Response.json(
        body:
            'Ticket Type with ID `${ticketBuyRequest.ticketRequest.ticketType}`'
            ' not found',
        statusCode: 404,
      );
    }
    if (ticketType.soldOut) {
      return Response.json(
        body: {'message': 'This ticket type is sold out', 'soldOut': true},
        statusCode: 400,
      );
    }

    // Check if we need to update the sold out status
    final isSoldOut = await checkTicketTypeSoldOut(
      ticketTypeId: ticketBuyRequest.ticketRequest.ticketType,
    );

    if (isSoldOut) {
      return Response.json(
        body: {'message': 'This ticket type is sold out', 'soldOut': true},
        statusCode: 400,
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
    ticketBuyRequest.paymentTransaction.description = '*Achat Tické* '
        'Ë: ${event.name}';
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
    printBlue('sckalerCollectionResponseJson: $sckalerCollectionResponseJson');
    final collectionTransaction = PaymentTransactionResponse.fromJson(
      sckalerCollectionResponseJson as Map<String, dynamic>,
    );

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
    printBlue('createTicketResponseJson: $createTicketResponseJson');
    final createdTicket = Ticket.fromJson(
      createTicketResponseJson as Map<String, dynamic>,
    );
    if (createTicketResponse.statusCode != 201) {
      printYellow(
        'Failed to create Ticket: $createTicketResponseJson',
      );
      return createTicketResponse;
    }

    // Then send ticket confirmation email
    final ticketConfirmationEmailResponse =
        await _mailRequestHandler.handleSendTicketConfirmationEmail(
      to: ticketBuyRequest.ticketRequest.issuedTo.email,
      subject: 'Your Event Ticket Confirmation',
      ticket: createdTicket,
      paymentTransactionResponse: collectionTransaction,
    );

    if (ticketConfirmationEmailResponse.statusCode != 200) {
      printYellow(
        'Failed to send Ticket Confirmation Email:'
        '\n$ticketConfirmationEmailResponse',
      );
      return ticketConfirmationEmailResponse;
    }

    final qrCodeUrl =
        'http://${await getPublicIpAddress()}:8080/api/qr?keyWord=${createTicketResponseJson['_id']}';

    return Response.json(
      body: {
        'message': 'Ticket purchased successfully',
        'ticket': createTicketResponseJson,
        'paymentInfo': sckalerCollectionResponseJson,
        'emailInfo': await ticketConfirmationEmailResponse.json(),
        'qrCodeUrl': qrCodeUrl,
      },
      statusCode: 201,
    );
  }
}
