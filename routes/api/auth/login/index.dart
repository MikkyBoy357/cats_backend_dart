import 'dart:convert';

import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/data/repositories/auth/user_repository.dart';
import 'package:cats_backend/services/services.dart';
import 'package:cats_backend/util/util.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  final mongoService = await context.read<Future<MongoService>>();

  final userRepository = UserRepository(
    database: mongoService.database,
  );

  try {
    final request = context.request;
    final mongoDbService = await context.read<Future<MongoService>>();
    print('passed mongoDbService initialization');

    if (request.method == HttpMethod.post) {
      await mongoDbService.open();
      print('DB is initialized: ${mongoDbService.isInitialized}');

      print('passed mongoDbService open');

      final requestBody = await request.body();
      print('requestBody: $requestBody');
      final requestData = jsonDecode(requestBody) as Map<String, dynamic>;
      print('requestData: $requestBody');

      print('finding user with email: ${requestData['email']}');
      final foundUser = await userRepository.getByEmail(
        requestData['email'] as String,
      );
      print('foundUser: $foundUser');

      if (foundUser == null) {
        return Response.json(
          statusCode: 400,
          body: {
            'status': 400,
            'message': 'No user found with the provided credentials',
            'error': 'user_not_found',
          },
        );
      }

      final foundUserPassword = foundUser.password;
      final hashedPassword = (requestData['password'] as String).hashValue;

      if (hashedPassword != foundUserPassword) {
        return Response.json(
          statusCode: 400,
          body: {
            'status': 400,
            'message': 'Incorrect email or password',
            'error': 'incorrect_email_password',
          },
        );
      }

      final foundUserId = foundUser.$_id.oid;

      final token = createJwt(foundUserId);

      return Response.json(
        body: {
          'status': 200,
          'message': 'User logged in successfully',
          'token': token,
        },
      );
    } else {
      return Response.json(
        statusCode: 404,
        body: {
          'status': 404,
          'message': 'Invalid request',
        },
      );
    }
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {
        'status': 500,
        'message': 'Server error. Something went wrong',
        'error': e.toString(),
      },
    );
  }
}
