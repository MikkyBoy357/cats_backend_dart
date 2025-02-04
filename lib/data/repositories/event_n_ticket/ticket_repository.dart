import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/helpers/helpers.dart';
import 'package:mongo_dart/mongo_dart.dart';

abstract class TicketRepositoryImpl {
  // Tickets
  Future<List<Ticket>> getTickets();
  Future<List<Ticket>> getTicketsByTicketType({required ObjectId ticketTypeId});
  Future<String?> getNextTicketNumber({required TicketType ticketType});
  Future<Ticket?> getTicketById({required ObjectId ticketId});
  Future<Ticket?> getTicketByTicketNumber({required String ticketNumber});
  Future<Ticket?> createTicket({required TicketRequest ticketRequest});
}

class TicketRepository extends TicketRepositoryImpl {
  final Db _database;

  TicketRepository({
    required Db database,
  }) : _database = database;

  DbCollection get _ticketsCollection => _database.ticketsCollection;

  List<PopulateField> get _ticketPopulateFields => [
        PopulateField(fieldName: 'ticketType', collectionName: 'ticketTypes'),
        PopulateField(
          fieldName: 'event',
          collectionName: 'events',
          subPopulateFields: [
            PopulateField(
              fieldName: 'ticketType',
              collectionName: 'ticketTypes',
            ),
            PopulateField(fieldName: 'createdBy', collectionName: 'users'),
            PopulateField(
              fieldName: 'categories',
              collectionName: 'eventCategories',
            ),
          ],
        ),
      ];

  @override
  Future<List<Ticket>> getTickets() async {
    final res = await _ticketsCollection.findAndPopulateRikky(
      _ticketPopulateFields,
    );
    printGreen('Tickets: $res');

    final tickets = res.map((e) => Ticket.fromJson(e)).toList();

    return tickets;
  }

  @override
  Future<List<Ticket>> getTicketsByTicketType({
    required ObjectId ticketTypeId,
  }) async {
    // Query tickets by ticketTypeId
    final queryDocs =
        _ticketsCollection.find(where.eq('ticketType', ticketTypeId)).toList();

    // Use the findAndPopulateLol to populate the fields
    final populatedDocs = await _ticketsCollection.findAndPopulateLol(
      _ticketPopulateFields,
      queryDocs,
    );

    // Convert the result to a list of Ticket objects
    final tickets = populatedDocs.map((doc) => Ticket.fromJson(doc)).toList();

    return tickets;
  }

  @override
  Future<String?> getNextTicketNumber({
    required TicketType ticketType,
  }) async {
    final ticketsOfType = await getTicketsByTicketType(
      ticketTypeId: ticketType.id,
    );

    if (ticketsOfType.isEmpty) {
      return '${ticketType.codePrefix}-000001'; // First ticket number
    }

    // Sort tickets by ticket number
    ticketsOfType.sort((a, b) => a.ticketNumber.compareTo(b.ticketNumber));

    // Get the last ticket and its ticket number
    final lastTicket = ticketsOfType.last;
    final lastTicketNumber = lastTicket.ticketNumber;

    // Extract the numeric suffix (after the dash)
    final suffix = lastTicketNumber.split('-').last;
    print('Suffix: $suffix');

    // Convert the suffix to an integer and increment it
    final nextSuffix =
        (int.parse(suffix) + 1).toString().padLeft(suffix.length, '0');
    print('Next suffix: $nextSuffix');

    final nextTicketNumber = '${ticketType.codePrefix}-$nextSuffix';
    return nextTicketNumber;
  }

  @override
  Future<Ticket?> getTicketById({required ObjectId ticketId}) async {
    final result = await _ticketsCollection.findOneAndPopulateRikky(
      {
        '_id': ticketId,
      },
      fieldsToPopulate: [
        PopulateField(fieldName: 'ticketType', collectionName: 'ticketTypes'),
        PopulateField(
          fieldName: 'event',
          collectionName: 'events',
          subPopulateFields: [
            PopulateField(
              fieldName: 'ticketType',
              collectionName: 'ticketTypes',
            ),
            PopulateField(fieldName: 'createdBy', collectionName: 'users'),
            PopulateField(
              fieldName: 'categories',
              collectionName: 'eventCategories',
            ),
          ],
        ),
      ],
    );

    printGreen('Ticket: $result');

    if (result == null) {
      return null;
    }

    return Ticket.fromJson(result);
  }

  @override
  Future<Ticket?> getTicketByTicketNumber({
    required String ticketNumber,
  }) async {
    final result = await _ticketsCollection.findOneAndPopulateRikky(
      {
        'ticketNumber': ticketNumber,
      },
      fieldsToPopulate: [
        PopulateField(fieldName: 'ticketType', collectionName: 'ticketTypes'),
        PopulateField(
          fieldName: 'event',
          collectionName: 'events',
          subPopulateFields: [
            PopulateField(
              fieldName: 'ticketType',
              collectionName: 'ticketTypes',
            ),
            PopulateField(fieldName: 'createdBy', collectionName: 'users'),
            PopulateField(
              fieldName: 'categories',
              collectionName: 'eventCategories',
            ),
          ],
        ),
      ],
    );

    printGreen('Ticket: $result');

    if (result == null) {
      return null;
    }

    return Ticket.fromJson(result);
  }

  @override
  Future<Ticket?> createTicket({required TicketRequest ticketRequest}) async {
    final result = await _ticketsCollection.insertOne(ticketRequest.toJson());
    print('Create Ticket result: $result');

    if (result.writeError != null) {
      return null;
    }

    if (result.id is ObjectId) {
      final ticketId = result.id as ObjectId;
      final ticket = await getTicketById(ticketId: ticketId);
      return ticket;
    }

    return null;
  }
}
