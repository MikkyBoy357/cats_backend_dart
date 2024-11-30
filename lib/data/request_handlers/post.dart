import 'package:cats_backend/common/common.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../../common/constants/storage_directories.dart';
import '../repositories/file_upload/file_upload.dart';
import '../repositories/post/post_repository.dart';

abstract class PostRequestHandler {
  Future<Response> handleCreatePost({
    required User saint,
    required FormData formData,
  });
  Future<Response> handleGetPostById({
    required ObjectId postId,
  });
  Future<Response> handleGetPostsByUserId({
    required ObjectId userId,
  });
}

class PostRequestHandlerImpl implements PostRequestHandler {
  final PostRepository _postRepository;

  const PostRequestHandlerImpl({
    required PostRepository postRepository,
  }) : _postRepository = postRepository;

  @override
  Future<Response> handleCreatePost({
    required User saint,
    required FormData formData,
  }) async {
    print('===> POST <==> Post:');
    final errors = <String?>[];
    final mediaUrls = <String>[];

    final caption = formData.fields['caption'];
    if (caption == null) {
      return Response.json(
        body: 'Error: Caption is required.',
        statusCode: 400,
      );
    }

    /// Check if there is image in the form data

    final files = formData.files;
    if (files.isNotEmpty) {
      final files = await FileUpload.getFilesFromFormData(formData);
      printYellow('MyFiles: \n${files.map((e) => '${e.name}\n')}');
      printGreen('${files.length} files found in the form data.');

      final uploadResults = await FileUpload.uploadMultipleFilesAndReturnUrls(
        uploadedFiles: files,
        storageDir: StorageDirectories.postsByUserId(userId: saint.$_id.oid),
        maxFiles: 3,
      );

      errors.addAll(
        uploadResults.map((e) => e.error).toList().where((e) => e != null),
      );
      mediaUrls.addAll(
        uploadResults.where((e) => e.url != null).map((e) => e.url!).toList(),
      );
    } else {
      printYellow('No files found in the form data.');
    }

    if (errors.isNotEmpty) {
      return Response.json(
        body: {
          'message': 'Failed to upload image',
          'errors': errors,
        },
        statusCode: 500,
      );
    }

    final post = await _postRepository.createPost(
      userId: saint.$_id,
      caption: caption,
      mediaUrls: mediaUrls,
    );

    return Response.json(
      body: post,
      statusCode: post != null ? 201 : 400,
    );
  }

  @override
  Future<Response> handleGetPostById({
    required ObjectId postId,
  }) async {
    final post = await _postRepository.getPostById(postId: postId);

    return Response.json(
      body: post,
      statusCode: post != null ? 200 : 404,
    );
  }

  @override
  Future<Response> handleGetPostsByUserId({
    required ObjectId userId,
  }) async {
    final posts = await _postRepository.getPostsByUserId(userId: userId);
    return Response.json(
      body: posts,
      statusCode: posts.isNotEmpty ? 200 : 404,
    );
  }
}
