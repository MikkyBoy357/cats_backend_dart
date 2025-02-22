import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/helpers/helpers.dart';
import 'package:mongo_dart/mongo_dart.dart';

abstract class TicketTypeRepositoryImpl {
  // TicketTypes
  Future<List<TicketTypeResponse>> getTicketTypes();
  Future<List<TicketType>> getTicketTypesByEventId({required ObjectId eventId});
  Future<TicketType?> createTicketType({required TicketType ticketType});
  Future<TicketType?> getTicketTypeById({required ObjectId ticketTypeId});
  Future<({List<TicketType> ticketTypes, List<ObjectId> missingIds})>
      getMultipleTicketTypeById({
    required List<ObjectId> ticketTypeIds,
  });
  Future<bool> deleteTicketType({required ObjectId ticketTypeId});
}

class TicketTypeRepository extends TicketTypeRepositoryImpl {
  final Db _database;

  TicketTypeRepository({
    required Db database,
  }) : _database = database;

  DbCollection get _ticketTypesCollection => _database.ticketTypesCollection;

  @override
  Future<List<TicketTypeResponse>> getTicketTypes() async {
    final res = await _ticketTypesCollection.findAndPopulateRikky(
      [
        // PopulateField(fieldName: 'createdBy', collectionName: 'users'),
      ],
    );
    printGreen('TicketTypes: $res');

    final ticketTypes = res.map((e) => TicketTypeResponse.fromJson(e)).toList();

    return ticketTypes;
  }

  @override
  Future<List<TicketType>> getTicketTypesByEventId({
    required ObjectId eventId,
  }) async {
    final res = await _ticketTypesCollection.findAndPopulateRikky(
      [
        // PopulateField(fieldName: 'createdBy', collectionName: 'users'),
      ],
    );
    printGreen('TicketTypes: $res');

    final ticketTypes = res.map((e) => TicketType.fromJson(e)).toList();

    return ticketTypes;
  }

  @override
  Future<TicketType?> createTicketType({required TicketType ticketType}) async {
    final result = await _ticketTypesCollection.insertOne(ticketType.toJson());

    if (result.writeError != null) {
      return null;
    }

    return ticketType;
  }

  @override
  Future<TicketType?> getTicketTypeById({
    required ObjectId ticketTypeId,
  }) async {
    final result = await _ticketTypesCollection.findOne({
      '_id': ticketTypeId,
    });

    if (result == null) {
      return null;
    }

    return TicketType.fromJson(result);
  }

  @override
  Future<({List<TicketType> ticketTypes, List<ObjectId> missingIds})>
      getMultipleTicketTypeById({
    required List<ObjectId> ticketTypeIds,
  }) async {
    final result = await _ticketTypesCollection.find({
      '_id': {r'$in': ticketTypeIds},
    }).toList();

    // Convert fetched documents to TicketType objects
    final ticketTypes =
        result.map((json) => TicketType.fromJson(json)).toList();

    // Extract existing IDs from the result
    final existingIds = ticketTypes.map((ticket) => ticket.id).toSet();

    // Find missing IDs
    final missingIds =
        ticketTypeIds.where((id) => !existingIds.contains(id)).toList();

    return (ticketTypes: ticketTypes, missingIds: missingIds);
  }

  @override
  Future<bool> deleteTicketType({required ObjectId ticketTypeId}) async {
    final result = await _ticketTypesCollection.deleteOne({
      '_id': ticketTypeId,
    });

    if (result.writeError != null) {
      return false;
    }

    return true;
  }
}
