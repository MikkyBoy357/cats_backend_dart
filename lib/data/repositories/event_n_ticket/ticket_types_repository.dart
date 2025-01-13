import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/helpers/helpers.dart';
import 'package:mongo_dart/mongo_dart.dart';

abstract class TicketTypeRepositoryImpl {
  // TicketTypes
  Future<List<TicketType>> getTicketTypes();
  Future<List<TicketType>> getTicketTypesByEventId({required ObjectId eventId});
  Future<TicketType?> createTicketType({required TicketType ticketType});
  Future<TicketType?> getTicketTypeById({required ObjectId ticketTypeId});
  Future<bool> deleteTicketType({required ObjectId ticketTypeId});
}

class TicketTypeRepository extends TicketTypeRepositoryImpl {
  final Db _database;

  TicketTypeRepository({
    required Db database,
  }) : _database = database;

  DbCollection get _ticketTypesCollection => _database.ticketTypesCollection;

  @override
  Future<List<TicketType>> getTicketTypes() async {
    final ticketTypesCollectionExt = DbCollectionExt(_ticketTypesCollection);

    final res = await ticketTypesCollectionExt.findAndPopulate(
      [
        // PopulateField(fieldName: 'eventId', collectionName: 'events'),
      ],
    );
    printGreen('TicketTypes: $res');

    final ticketTypes = res.map((e) => TicketType.fromJson(e)).toList();

    return ticketTypes;
  }

  @override
  Future<List<TicketType>> getTicketTypesByEventId({
    required ObjectId eventId,
  }) async {
    final ticketTypesCollectionExt = DbCollectionExt(_ticketTypesCollection);

    final res = await ticketTypesCollectionExt.findAndPopulate(
      [
        PopulateField(fieldName: 'eventId', collectionName: 'events'),
      ],
    );
    printGreen('TicketTypes: $res');

    final ticketTypes = res.map((e) => TicketType.fromJson(e)).toList();

    return ticketTypes;
  }

  @override
  Future<TicketType?> createTicketType({required TicketType ticketType}) async {
    final result = await _ticketTypesCollection.insertOne(ticketType.toJson());
    print('Create TicketType result: $result');

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
