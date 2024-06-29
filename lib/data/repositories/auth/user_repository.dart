import 'package:cats_backend/common/common.dart';
import 'package:mongo_dart/mongo_dart.dart';

enum UserQuery {
  id('_id'),
  email('email'),
  username('username');

  final String value;
  const UserQuery(this.value);
}

enum FollowedFollowerQuery {
  id('_id'),
  followedId('followedId'),
  followerId('followerId');

  final String value;
  const FollowedFollowerQuery(this.value);
}

abstract class UserRepositoryImpl {
  Future<User?> getQuery(UserQuery query, String keyword);
  Future<List<FollowedFollower>?> getFollowedFollowerQuery(
    FollowedFollowerQuery query,
    String keyword,
  );

  Future<FollowedFollower?> postFollowedFollower(
    FollowedFollower followedFollower,
  );

  Future<bool> deleteFollowedFollower(
    FollowedFollower followedFollower,
  );
}

class UserRepository implements UserRepositoryImpl {
  final Db _database;

  UserRepository({
    required Db database,
  }) : _database = database;

  DbCollection get usersCollection => _database.usersCollection;
  DbCollection get followersCollection => _database.followersCollection;

  @override
  Future<User?> getQuery(UserQuery query, String keyword) async {
    dynamic parsedKeyword = keyword;
    if (query == UserQuery.id) {
      parsedKeyword = ObjectId.parse(keyword);
    }

    final foundUser = await usersCollection.findOne({
      query.value: parsedKeyword,
    });
    print('====> foundUser: $foundUser');
    return foundUser != null ? User.fromMap(foundUser) : null;
  }

  @override
  Future<List<FollowedFollower>?> getFollowedFollowerQuery(
    FollowedFollowerQuery query,
    String keyword,
  ) async {
    final parsedKeyword = ObjectId.fromHexString(keyword);

    final followers = await followersCollection.find({
      query.value: parsedKeyword,
    }).toList();

    print('lol -> \n$followers');

    final parsedFollowers = followers.map((f) {
      return FollowedFollower.fromJson(f);
    }).toList();

    return parsedFollowers;
  }

  @override
  Future<FollowedFollower?> postFollowedFollower(
    FollowedFollower followedFollower,
  ) async {
    final result = await followersCollection.insertOne(
      followedFollower.toJson(),
    );

    if (result.writeError != null) {
      return null;
    }

    return followedFollower.copyWith(
      $_id: result.id as ObjectId,
    );
  }

  @override
  Future<bool> deleteFollowedFollower(
    FollowedFollower followedFollower,
  ) async {
    final result = await followersCollection.deleteOne({
      FollowedFollowerQuery.followerId.name: followedFollower.followerId,
      FollowedFollowerQuery.followedId.name: followedFollower.followedId,
    });

    if (result.writeError != null) {
      return false;
    }

    return true;
  }
}
