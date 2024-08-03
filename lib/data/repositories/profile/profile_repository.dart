import 'package:cats_backend/common/common.dart';
import 'package:mongo_dart/mongo_dart.dart';

abstract class ProfileRepositoryImpl {
  Future<User?> changeProfileAvatar({
    required User user,
    required String imageUrl,
  });
  // implement changeProfileBio
  // see changeProfileAvatar for example
}

class ProfileRepository extends ProfileRepositoryImpl {
  final Db _database;

  ProfileRepository({
    required Db database,
  }) : _database = database;

  DbCollection get usersCollection => _database.usersCollection;

  @override
  Future<User?> changeProfileAvatar({
    required User user,
    required String imageUrl,
  }) async {
    final result = await usersCollection.updateOne(
      where.id(user.$_id),
      modify.set('avatarUrl', imageUrl),
    );

    print('📍 Write result: $result');

    if (result.writeError != null) {
      return null;
    }

    final updatedUser = user.copyWith(avatarUrl: imageUrl);

    return User.fromJson(updatedUser.toJson());
  }

  // implement changeProfileBio
  // see changeProfileAvatar for example
}
