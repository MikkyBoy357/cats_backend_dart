import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/helpers/helpers.dart';
import 'package:mongo_dart/mongo_dart.dart';

abstract class TicketRepositoryImpl {
  // Tickets
  Future<List<Ticket>> getTickets();
  Future<List<Ticket>> getTicketsByTicketType({required ObjectId ticketTypeId});
  Future<String?> getNextTicketNumber({required TicketType ticketType});
  Future<Ticket?> getTicketById({
    required ObjectId ticketId,
    List<PopulateField>? fieldsToPopulate,
  });
  Future<Ticket?> getTicketByTicketNumber({
    required String ticketNumber,
    bool populate = true,
  });
  Future<Ticket?> createTicket({required TicketRequest ticketRequest});
  Future<List<Ticket>> getTicketsByEventId({required ObjectId eventId});
  Future<Ticket?> scanTicket({
    required ObjectId ticketId,
    required ObjectId scannedBy,
  });
}

class TicketRepository extends TicketRepositoryImpl {
  final Db _database;

  TicketRepository({
    required Db database,
  }) : _database = database;

  DbCollection get _ticketsCollection => _database.ticketsCollection;

  List<PopulateField> get _ticketPopulateFields => [
        PopulateField(fieldName: 'ticketType', collectionName: 'ticketTypes'),
        PopulateField(fieldName: 'scannedBy', collectionName: 'users'),
        PopulateField(
          fieldName: 'event',
          collectionName: 'events',
          subPopulateFields: [
            PopulateField(
              fieldName: 'ticketTypes',
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
  Future<List<Ticket>> getTicketsByEventId({
    required ObjectId eventId,
  }) async {
    final queryDocs = _ticketsCollection
        .find(
          where.eq('event', eventId),
        )
        .toList();

    final populatedDocs = await _ticketsCollection.findAndPopulateLol(
      [],
      queryDocs,
    );

    final tickets = populatedDocs.map((doc) => Ticket.fromJson(doc)).toList();

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
      [
        // ..._ticketPopulateFields,
      ],
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
    // --- OPTIMIZED CODE START ---
    final lastTicketDoc = await _ticketsCollection.findOne(
      where
          .eq('ticketType', ticketType.id)
          .sortBy(
            'ticketNumber',
            descending: true,
          ) // Sort by ticketNumber descending
          .limit(1), // Get only the first (i.e., last) document
    );

    if (lastTicketDoc == null) {
      return '${ticketType.codePrefix}-000001'; // First ticket number
    }

    final lastTicketNumber = lastTicketDoc['ticketNumber'] as String;

    // Extract the numeric suffix (after the dash)
    final suffix = lastTicketNumber.split('-').last;
    printMagenta(
      'Last Ticket Suffix: $suffix',
    ); // Changed print message for clarity

    // Convert the suffix to an integer and increment it
    // Ensure the suffix length is maintained for proper padding
    final nextSuffix =
        (int.parse(suffix) + 1).toString().padLeft(suffix.length, '0');
    printMagenta('Next Suffix: $nextSuffix');

    final nextTicketNumber = '${ticketType.codePrefix}-$nextSuffix';
    return nextTicketNumber;
    // --- OPTIMIZED CODE END ---
  }

  @override
  Future<Ticket?> getTicketById({
    required ObjectId ticketId,
    List<PopulateField>? fieldsToPopulate,
  }) async {
    final result = await _ticketsCollection.findOneAndPopulateRikky(
      {
        '_id': ticketId,
      },
      fieldsToPopulate: () {
        if (fieldsToPopulate != null) {
          return fieldsToPopulate;
        }

        if (fieldsToPopulate == null) {
          return _ticketPopulateFields;
        }

        return <PopulateField>[];
      }(),
    );

    printGreen('Ticket: $result');

    if (result == null) {
      return null;
    }

    return Ticket.fromJson(result);
  }

  @override
  Future<Ticket?> scanTicket({
    required ObjectId ticketId,
    required ObjectId scannedBy,
  }) async {
    final stopwatch = Stopwatch()..start();

    final now = DateTime.now();
    final scanEntry = ScanEntry(
      scannedAt: now,
      success: true,
    );

    final updateResult = await _ticketsCollection.updateOne(
      where.eq('_id', ticketId),
      {
        r'$set': {
          'isScanned': true,
          'scannedAt': now.toString(),
          'scannedBy': scannedBy,
        },
        r'$push': {
          'scanHistory': scanEntry.toJson(),
        },
      },
    );

    if (updateResult.isSuccess) {
      return getTicketById(ticketId: ticketId);
    }

    printRed('UpdateResult: ${updateResult.writeError?.errmsg.toString()}');

    stopwatch.stop();
    printBlue('ScanTicket took: ${stopwatch.elapsedMilliseconds} ms');

    return null;
  }

  @override
  Future<Ticket?> getTicketByTicketNumber({
    required String ticketNumber,
    bool populate = true,
  }) async {
    final result = await _ticketsCollection.findOneAndPopulateRikky(
      {
        'ticketNumber': ticketNumber,
      },
      fieldsToPopulate: [
        if (populate) ..._ticketPopulateFields,
        PopulateField(fieldName: 'ticketType', collectionName: 'ticketTypes'),
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
