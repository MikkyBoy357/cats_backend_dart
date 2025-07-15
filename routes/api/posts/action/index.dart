import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/helpers/helpers.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';
// import 'package:dart_frog/src/body_parsers/form_data.dart';

Future<Response> onRequest(RequestContext context) async {
  final authValidationResponse = context.read<AuthValidationResponse>();

  if (!authValidationResponse.isValid) {
    return Response.json(
      statusCode: 401,
      body: 'Auth Error: ${authValidationResponse.errorMessage}',
    );
  }

  final saint = authValidationResponse.user!;

  final postRepository =
      PostRepository(database: await mongoDbPoolService.acquire());
  final request = context.request;
  final method = request.method;
  final handler = PostRequestHandlerImpl(postRepository: postRepository);

  return switch (method) {
    HttpMethod.get => Future.value(Response.json(body: 'GET request')),
    HttpMethod.post => () async {
        final formData = await request.formData();

        final files = formData.files;

        // content type: multipart/form-data
        printYellow('NEW POST: ${files.length} FILES');
        printYellow('FILES lol: $formData');

        return handler.handleCreatePost(
          saint: saint,
          formData: formData,
        );
      }(),
    HttpMethod.put => Future.value(Response.json(body: 'PUT request')),
    HttpMethod.delete => Future.value(Response.json(body: 'DELETE request')),
    _ => Future.value(Response.json(body: 'Invalid request method')),
  };
}
