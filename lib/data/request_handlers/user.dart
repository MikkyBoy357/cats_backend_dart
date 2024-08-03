import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/data/data.dart';
import 'package:dart_frog/dart_frog.dart';

abstract class UserRequestHandler {
  Future<Response> getUserByQuery(
    UserQuery query,
    String keyword,
  );
  Future<Response> getUserFollowers(
    FollowedFollowerQuery query,
    String keyword,
  );
  Future<Response> getUserFollowings(
    FollowedFollowerQuery query,
    String keyword,
  );

  Future<Response> postUserFollowers(FollowedFollower followedFollower);
}

class UserRequestHandlerImpl implements UserRequestHandler {
  final UserRepository _userRepository;

  UserRequestHandlerImpl({
    required UserRepository userRepository,
  }) : _userRepository = userRepository;

  @override
  Future<Response> getUserByQuery(UserQuery query, String keyword) async {
    final user = await _userRepository.getQuery(query, keyword);
    if (user != null) {
      // get followers count and following count of the user
      final followersFollowingsCounts =
          await _userRepository.getFollowersFollowingsCounts(user.$_id.oid);
      user
        ..followersCount = followersFollowingsCounts.followersCount
        ..followingsCount = followersFollowingsCounts.followingsCount

        // omit password
        ..password = null;
      return Response.json(body: user);
    }
    return Response.json(body: 'User not found', statusCode: 404);
  }

  @override
  Future<Response> getUserFollowers(
    FollowedFollowerQuery query,
    String keyword,
  ) async {
    final followedFollower = await _userRepository.getFollowedFollowerQuery(
      query,
      keyword,
      lookups: [
        SaintLookup(
          from: 'users',
          localField: 'followerId',
          foreignField: '_id',
          as: 'followerObject',
        ),
      ],
    );

    final followers = followedFollower!.map((e) {
      return e['followerObject'] as Map<String, dynamic>;
    }).toList();

    final followersUserObjects =
        followers.map((e) => User.fromJson(e)).toList();

    // Get followers count and following count of each user
    for (final user in followersUserObjects) {
      final followersFollowingsCounts =
          await _userRepository.getFollowersFollowingsCounts(user.$_id.oid);

      print('====> followersFollowingsCounts: $followersFollowingsCounts');

      user
        ..followersCount = followersFollowingsCounts.followersCount
        ..followingsCount = followersFollowingsCounts.followingsCount;
    }

    return Response.json(body: followersUserObjects);
  }

  @override
  Future<Response> getUserFollowings(
    FollowedFollowerQuery query,
    String keyword,
  ) async {
    final followedFollower = await _userRepository.getFollowedFollowerQuery(
      query,
      keyword,
      lookups: [
        SaintLookup(
          from: 'users',
          localField: 'followedId',
          foreignField: '_id',
          as: 'followedObject',
        ),
      ],
    );

    final followings = followedFollower!.map((e) {
      return e['followedObject'] as Map<String, dynamic>;
    }).toList();

    final followingsUserObjects =
        followings.map((e) => User.fromJson(e)).toList();

    // Get followings count and following count of each user
    for (final user in followingsUserObjects) {
      final followersFollowingsCounts =
          await _userRepository.getFollowersFollowingsCounts(user.$_id.oid);

      user
        ..followersCount = followersFollowingsCounts.followersCount
        ..followingsCount = followersFollowingsCounts.followingsCount;
    }

    return Response.json(body: followingsUserObjects);
  }

  @override
  Future<Response> postUserFollowers(FollowedFollower followedFollower) async {
    print('====> followedFollower: ${followedFollower.toJson()}');
    // check if the follower and followed are the same
    if (followedFollower.followerId == followedFollower.followedId) {
      return Response.json(
        statusCode: 400,
        body: {
          'statusCode': 400,
          'message': 'Cannot follow yourself',
        },
      );
    }

    // check if the follower is already following the followed
    final existingFollowedFollower =
        await _userRepository.getFollowedFollowerQuery(
      FollowedFollowerQuery.followerId,
      followedFollower.followerId.oid,
    );

    print('====> existingFollowedFollower: $existingFollowedFollower');

    // if the follower is already following the followed, unfollow
    if (existingFollowedFollower!.isNotEmpty) {
      final unfollowSuccess = await _userRepository.deleteFollowedFollower(
        followedFollower,
      );

      if (unfollowSuccess) {
        return Response.json(statusCode: 202, body: 'Unfollowed');
      }

      return Response.json(statusCode: 500, body: 'Unfollow failed');
    }

    // if the follower is not following the followed, follow
    final followResult = await _userRepository.postFollowedFollower(
      followedFollower,
    );
    if (followResult != null) {
      return Response.json(statusCode: 201, body: 'Followed');
    }

    return Response.json(statusCode: 500, body: 'Followed');
  }
}
