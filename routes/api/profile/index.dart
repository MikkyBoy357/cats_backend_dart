import 'package:cats_backend/helpers/authentication_validation.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  final authValidationResponse = context.read<AuthValidationResponse>();

  if (!authValidationResponse.isValid) {
    return Response.json(
      statusCode: 401,
      body: 'Auth Error: ${authValidationResponse.errorMessage}',
    );
  }

  final saint = authValidationResponse.user!;

  final request = context.request;
  final method = request.method;

  return switch (method) {
    HttpMethod.get => Future.value(
        Response.json(
          body: saint,
        ),
      ),
    _ => Future.value(
        Response.json(
          body: 'Method not allowed',
          statusCode: 405,
        ),
      ),
  };
}
