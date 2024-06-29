import 'package:mongo_dart/mongo_dart.dart';

class FollowedFollower {
  ObjectId? $_id;
  ObjectId followedId;
  ObjectId followerId;

  FollowedFollower({
    this.$_id,
    required this.followerId,
    required this.followedId,
  });

  factory FollowedFollower.fromJson(Map<String, dynamic> json) {
    return FollowedFollower(
      $_id: json['_id'] as ObjectId?,
      followedId: json['followedId'] as ObjectId,
      followerId: json['followerId'] as ObjectId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': $_id,
      'followedId': followedId,
      'followerId': followerId,
    };
  }

  FollowedFollower copyWith({
    ObjectId? $_id,
    ObjectId? followedId,
    ObjectId? followerId,
  }) {
    return FollowedFollower(
      $_id: $_id ?? this.$_id,
      followedId: followedId ?? this.followedId,
      followerId: followerId ?? this.followerId,
    );
  }
}
