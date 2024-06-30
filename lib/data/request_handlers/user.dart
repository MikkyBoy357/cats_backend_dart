import 'package:cats_backend/common/models/models.dart';
import 'package:cats_backend/data/data.dart';
import 'package:dart_frog/dart_frog.dart';

import '../../common/extensions/saint_lookup.dart';

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

    final followers =
        followedFollower!.map((e) => e['followerObject']).toList();

    return Response.json(body: followers);
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

    final followings =
        followedFollower!.map((e) => e['followedObject']).toList();

    return Response.json(body: followings);
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
