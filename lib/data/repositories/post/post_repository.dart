import 'package:cats_backend/common/common.dart';
import 'package:mongo_dart/mongo_dart.dart';

abstract class PostRepositoryImpl {
  Future<Post?> createPost({
    required ObjectId userId,
    required String caption,
    List<String>? mediaUrls,
  });

  Future<Post?> getPostById({required ObjectId postId});

  Future<List<Post?>> getPostsByUserId({required ObjectId userId});

  // Future<Post?> getPostById({required ObjectId postId});

  // Future<Post?> updatePost({
  //   required ObjectId postId,
  //   required String caption,
  //   List<String>? mediaUrls,
  // });

  // Future<bool?> deletePost({required ObjectId postId});
}

class PostRepository extends PostRepositoryImpl {
  final Db _database;

  PostRepository({
    required Db database,
  }) : _database = database;

  DbCollection get _postsCollection => _database.collection('posts');

  @override
  Future<Post?> createPost({
    required ObjectId userId,
    required String caption,
    List<String>? mediaUrls,
  }) async {
    final post = Post(
      id: ObjectId(),
      userId: userId,
      caption: caption,
      mediaUrls: mediaUrls ?? [],
      postTimestamp: DateTime.now(),
    );

    await _postsCollection.insert(post.toJson());

    return post;
  }

  @override
  Future<Post?> getPostById({required ObjectId postId}) async {
    final post = await _postsCollection.findOne({
      '_id': postId,
    });

    return post == null ? null : Post.fromJson(post);
  }

  @override
  Future<List<Post?>> getPostsByUserId({required ObjectId userId}) async {
    final posts = await _postsCollection.find({
      'userId': userId,
    }).toList();

    return posts.map((e) => Post.fromJson(e)).toList();
  }
}
