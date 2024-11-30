import 'package:mongo_dart/mongo_dart.dart';

class Post {
  final ObjectId id;
  final ObjectId userId;
  final String caption;
  final List<String> mediaUrls;
  final DateTime postTimestamp;

  Post({
    required this.id,
    required this.userId,
    required this.caption,
    this.mediaUrls = const [],
    required this.postTimestamp,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id'] as ObjectId,
      userId: json['userId'] as ObjectId,
      caption: json['caption'] as String,
      mediaUrls: (json['mediaUrls'] == null)
          ? <String>[]
          : (json['mediaUrls'] as List).map((e) => e as String).toList(),
      postTimestamp: json['postTimestamp'] != null
          ? DateTime.parse(json['postTimestamp'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'caption': caption,
      'mediaUrls': mediaUrls,
      'postTimestamp': postTimestamp.toString(),
    };
  }

  Post copyWith({
    ObjectId? id,
    ObjectId? userId,
    String? caption,
    List<String>? mediaUrls,
    DateTime? postTimestamp,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      caption: caption ?? this.caption,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      postTimestamp: postTimestamp ?? this.postTimestamp,
    );
  }
}
