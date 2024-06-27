import 'package:cats_backend/common/common.dart';
import 'package:mongo_dart/mongo_dart.dart';

abstract class UserRepositoryImpl {
  Future<User?> getById(String id);
  Future<User?> getByObjectId(ObjectId id);
  Future<User?> getByEmail(String email);
}

class UserRepository implements UserRepositoryImpl {
  final Db _database;

  UserRepository({
    required Db database,
  }) : _database = database;

  DbCollection get usersCollection => _database.usersCollection;

  @override
  Future<User?> getById(String id) async {
    final foundUser = await usersCollection.findOne({
      '_id': ObjectId.fromHexString(id),
    });
    return foundUser != null ? User.fromMap(foundUser) : null;
  }

  @override
  Future<User?> getByObjectId(ObjectId id) async {
    final foundUser = await usersCollection.findOne({
      '_id': id,
    });
    return foundUser != null ? User.fromMap(foundUser) : null;
  }

  @override
  Future<User?> getByEmail(String email) async {
    final foundUser = await usersCollection.findOne({
      'email': email,
    });
    return foundUser != null ? User.fromMap(foundUser) : null;
  }
}
