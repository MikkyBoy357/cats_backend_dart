import 'package:cats_backend/models/models.dart';
import 'package:mongo_dart/mongo_dart.dart';

class LoginRepository {
  final Db _database;

  LoginRepository({
    required Db database,
  }) : _database = database;

  Future<User?> findUserByEmail(String email) async {
    final usersCollection = _database.collection('users');
    final foundUser = await usersCollection.findOne({'email': email});
    return foundUser != null ? User.fromMap(foundUser) : null;
  }
}
