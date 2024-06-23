import 'dart:convert';

import 'package:cats_backend/helpers/helpers.dart';
import 'package:cats_backend/repositories/login_repository.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

Future<Response> onRequest(RequestContext context) async {
  final mongoService = await context.read<Future<MongoService>>();

  final loginRepository = LoginRepository(
    database: mongoService.database,
  );

  try {
    final request = context.request;
    final mongoDbService = await context.read<Future<MongoService>>();
    print('passed mongoDbService initialization');

    if (request.method == HttpMethod.post) {
      await mongoDbService.open();
      print("DB is initialized: ${mongoDbService.isInitialized}");

      print('passed mongoDbService open');

      final requestBody = await request.body();
      print('requestBody: $requestBody');
      final requestData = jsonDecode(requestBody) as Map<String, dynamic>;
      print('requestData: $requestBody');

      print('finding user with email: ${requestData['email']}');
      final foundUser = await loginRepository.findUserByEmail(
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
      final hashedPassword = hashPassword(
        requestData['password'] as String,
      );

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

      final foundUserId = (foundUser.toMap()['_id'] as ObjectId).oid;

      final token = issueToken(foundUserId);

      await mongoDbService.close();

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
