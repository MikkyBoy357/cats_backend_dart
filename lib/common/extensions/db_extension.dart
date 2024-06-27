import 'package:mongo_dart/mongo_dart.dart';

extension DbX on Db {
  DbCollection get usersCollection => collection('users');
  DbCollection get catsCollection => collection('cats');
}
