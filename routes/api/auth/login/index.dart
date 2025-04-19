import 'dart:convert';

import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/services/services.dart';
import 'package:cats_backend/util/issue_token.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  final userRepository = UserRepository(
    database: mongoDbService.database,
  );

  try {
    final request = context.request;
    final mongoDbService = await context.read<Future<MongoService>>();
    printGreen('passed mongoDbService initialization');

    if (request.method == HttpMethod.post) {
      await mongoDbService.open();
      printGreen('DB is initialized: ${mongoDbService.isInitialized}');

      printBlue('passed mongoDbService open');

      final requestBody = await request.body();
      printMagenta('requestBody: $requestBody');
      final requestData = jsonDecode(requestBody) as Map<String, dynamic>;
      printYellow('requestData: $requestBody');

      // Allow login with either email or username
      final identifier = requestData['identifier'] as String;
      final password = requestData['password'] as String;
      printBlue('codeeee-->$identifier');
      // Determine if identifier is email or username
      final isEmail = identifier.contains('@');

      printBlue(
          'Finding user with ${isEmail ? 'email' : 'username'}: $identifier...');

      final foundUser = await userRepository.getQuery(
        isEmail ? UserQuery.email : UserQuery.username,
        identifier,
      );

      printBlue('foundUser: $foundUser');

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
      final hashedPassword = password.hashValue;

      if (hashedPassword != foundUserPassword) {
        return Response.json(
          statusCode: 400,
          body: {
            'status': 400,
            'message': 'Incorrect credentials',
            'error': 'incorrect_credentials',
          },
        );
      }

      final foundUserId = foundUser.$_id.oid;
      final token = issueToken(foundUserId);

      return Response.json(
        body: {
          'status': 200,
          'message': 'User logged in successfully',
          'token': token,
          'user': foundUser,
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
