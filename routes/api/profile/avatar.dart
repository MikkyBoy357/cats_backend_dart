import 'package:cats_backend/data/repositories/profile/profile_repository.dart';
import 'package:cats_backend/data/request_handlers/profile.dart';
import 'package:cats_backend/helpers/authentication_validation.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  print('======= avatar =======>');
  final authValidationResponse = context.read<AuthValidationResponse>();

  if (!authValidationResponse.isValid) {
    return Response.json(
      statusCode: 401,
      body: 'Auth Error: ${authValidationResponse.errorMessage}',
    );
  }

  final saint = authValidationResponse.user!;

  final profileRepository = ProfileRepository(
    database: mongoDbService.database,
  );
  final request = context.request;
  final method = request.method;
  final queryParams = request.uri.queryParameters;
  final handler = ProfileRequestHandlerImpl(
    profileRepository: profileRepository,
  );

  return switch (method) {
    HttpMethod.post => () async {
        final formData = await request.formData();

        return handler.handleChangeProfileAvatar(
          user: saint,
          formData: formData,
        );
      }(),
    _ => Future.value(
        Response.json(
          body: 'Method not allowed',
          statusCode: 405,
        ),
      ),
  };
}
