class FollowersFollowingsCounts {
  final int followersCount;
  final int followingsCount;

  FollowersFollowingsCounts({
    required this.followersCount,
    required this.followingsCount,
  });

  factory FollowersFollowingsCounts.zero() {
    return FollowersFollowingsCounts(
      followersCount: 0,
      followingsCount: 0,
    );
  }

  factory FollowersFollowingsCounts.fromJson(Map<String, dynamic> json) {
    return FollowersFollowingsCounts(
      followersCount: json['followersCount'] as int,
      followingsCount: json['followingsCount'] as int,
    );
  }

  Map<String, int> toJson() {
    return {
      'followersCount': followersCount,
      'followingsCount': followingsCount,
    };
  }
}
