import 'dart:convert';

import 'package:cats_backend/data/repositories/repositories.dart';
import 'package:cats_backend/data/request_handlers/profile.dart';
import 'package:cats_backend/helpers/authentication_validation.dart';
import 'package:cats_backend/services/mongo_service.dart';
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

  final profileRepository = ProfileRepository(
    database: mongoDbService.database,
  );
  final request = context.request;
  final method = request.method;
  final handler = ProfileRequestHandlerImpl(
    profileRepository: profileRepository,
  );
  final saint = authValidationResponse.user!;

  return switch (method) {
    HttpMethod.post => () async {
        final body = await request.body();
        final bodyJson = jsonDecode(body) as Map<String, dynamic>;

        final bio = bodyJson['bio'] as String?;

        if (bio == null || bio.isEmpty) {
          return Response.json(
            body: 'Error: Bio is required and cannot be empty.',
            statusCode: 400,
          );
        }

        return handler.handleChangeBio(
          user: saint,
          bio: bio,
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
