import 'package:cats_backend/common/common.dart';
import 'package:mongo_dart/mongo_dart.dart';

abstract class ProfileRepositoryImpl {
  Future<User?> changeProfileAvatar({
    required User user,
    required String imageUrl,
  });

  Future<User?> changeProfileBio({
    required User user,
    required String bio,
  });

  Future<User?> changeOnlineStatus({
    required User user,
    required bool isOnline,
  });
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

    return updatedUser;
  }

  @override
  Future<User?> changeProfileBio({
    required User user,
    required String bio,
  }) async {
    final result = await usersCollection.updateOne(
      where.id(user.$_id),
      modify.set('bio', bio),
    );

    print('📍 Write result: $result');

    if (result.writeError != null) {
      return null;
    }

    final updatedUser = user.copyWith(bio: bio);

    return updatedUser;
  }

  @override
  Future<User?> changeOnlineStatus({
    required User user,
    required bool isOnline,
  }) async {
    final lastSeen = DateTime.now();
    final result = await usersCollection.updateOne(
      where.id(user.$_id),
      modify.set('isOnline', isOnline).set('lastSeen', lastSeen),
    );

    print('📍 Write result: $result');

    if (result.writeError != null) {
      return null;
    }

    final updatedUser = user.copyWith(
      isOnline: isOnline,
      lastSeen: lastSeen,
    );

    return updatedUser;
  }
}
