import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/helpers/populate.dart';
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

// typedef FollowersFollowingsCounts = Map<String, int>;

abstract class UserRepositoryImpl {
  Future<User?> getQuery(UserQuery query, String keyword);
  Future<List<Map<String, dynamic>>?> getFollowedFollowerQuery(
    FollowedFollowerQuery query,
    String keyword, {
    List<SaintLookup>? lookups,
  });

  Future<FollowedFollower?> postFollowedFollower(
    FollowedFollower followedFollower,
  );

  Future<bool> deleteFollowedFollower(
    FollowedFollower followedFollower,
  );

  Future<FollowersFollowingsCounts> getFollowersFollowingsCounts(
    String userId,
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
  Future<List<Map<String, dynamic>>?> getFollowedFollowerQuery(
    FollowedFollowerQuery query,
    String keyword, {
    List<SaintLookup>? lookups,
  }) async {
    final parsedKeyword = ObjectId.fromHexString(keyword);

    final followedFollowers = await followersCollection.findAndPopulate(
      {
        query.value: parsedKeyword,
      },
      lookups: lookups ?? [],
    );

    if (followedFollowers == null) {
      return null;
    }

    print('====> test: $followedFollowers');

    return followedFollowers;
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

  @override
  Future<FollowersFollowingsCounts> getFollowersFollowingsCounts(
    String userId,
  ) async {
    final parsedKeyword = ObjectId.fromHexString(userId);
    print('meh -> $parsedKeyword');
    print('meh2 -> ${FollowedFollowerQuery.followedId}');

    final fallback = FollowersFollowingsCounts.zero();

    final followers = await getFollowedFollowerQuery(
      FollowedFollowerQuery.followedId,
      userId,
    );

    if (followers == null) {
      return fallback;
    }

    final followersCount = followers.length;

    final followings = await getFollowedFollowerQuery(
      FollowedFollowerQuery.followerId,
      userId,
    );

    if (followings == null) {
      return fallback;
    }
    final followingsCount = followings.length;

    return FollowersFollowingsCounts(
      followersCount: followersCount,
      followingsCount: followingsCount,
    );
  }
}
