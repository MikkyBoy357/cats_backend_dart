import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/helpers/helpers.dart';
import 'package:mongo_dart/mongo_dart.dart';

abstract class ComboTicketsRepositoryImpl {
  Future<List<Ticket>> getComboTickets();
  Future<Ticket?> getTicketById({
    required ObjectId ticketId,
    List<PopulateField>? fieldsToPopulate,
  });
  Future<List<Ticket>> getTicketsByEventId({required ObjectId eventId});
  Future<Ticket?> getTicketByComboCardNumber({
    required String comboCardNumber,
    bool populate = true,
  });
  Future<Ticket?> getTicketByTicketNumber({
    required String ticketNumber,
    bool populate = true,
  });
  Future<Ticket?> scanTicket({
    required ObjectId ticketId,
    required ObjectId scannedBy,
  });
}

class ComboTicketsRepository extends ComboTicketsRepositoryImpl {
  final Db _database;

  ComboTicketsRepository({
    required Db database,
  }) : _database = database;

  DbCollection get _ticketsCollection => _database.comboTicketsCollection;

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
  Future<List<Ticket>> getComboTickets() async {
    final tickets = await _ticketsCollection.find().toList();
    return tickets.map((ticket) => Ticket.fromJson(ticket)).toList();
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
  Future<Ticket?> getTicketByComboCardNumber({
    required String comboCardNumber,
    bool populate = true,
  }) async {
    final result = await _ticketsCollection.findOneAndPopulateRikky(
      {
        'comboCardNumber': comboCardNumber,
      },
      fieldsToPopulate: [
        if (populate) ..._ticketPopulateFields,
        PopulateField(fieldName: 'ticketType', collectionName: 'ticketTypes'),
      ],
    );

    if (result == null) {
      return null;
    }

    return Ticket.fromJson(result);
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
    final ticket = await getTicketById(ticketId: ticketId);

    if (ticket == null) {
      return null;
    }

    final now = DateTime.now();

    final scanEntry = ScanEntry(
      scannedAt: now,
      scannedBy: scannedBy,
      success: true,
    );

    ticket.scanHistory.add(scanEntry);

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
    printBlue('COMBO ScanTicket took: ${stopwatch.elapsedMilliseconds} ms');

    return null;
  }
}
