import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final postId = ObjectId.tryParse(id);
  if (postId == null) {
    return Response(
      body: 'Invalid post id: $id',
      statusCode: 400,
    );
  }

  final postRepository =
      PostRepository(database: await mongoDbPoolService.acquire());
  final request = context.request;
  final method = request.method;
  final handler = PostRequestHandlerImpl(postRepository: postRepository);

  return switch (method) {
    HttpMethod.get => await handler.handleGetPostById(
        postId: postId,
      ),
    _ => Response(
        body: 'Unsupported request method: $method',
        statusCode: 405,
      ),
  };
}
