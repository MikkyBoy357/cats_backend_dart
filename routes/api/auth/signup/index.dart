import 'dart:async';
import 'dart:convert';

import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/helpers/helpers.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  final userRepository = UserRepository(
    database: mongoDbService.database,
  );

  // final userRequestHandlerImpl = UserRequestHandlerImpl(
  //   userRepository: userRepository,
  // );

  try {
    final request = context.request;

    if (request.method == HttpMethod.post) {
      await mongoDbService.open();

      final requestBody = await request.body();
      final requestData = jsonDecode(requestBody) as Map<String, dynamic>;

      final email = requestData['email'] as String;
      final password = requestData['password'] as String;
      final name = requestData['name'] as String;
      final type = requestData['userType'] as String;
      final userType = _getUserTypeFromString(type);
      final hashedPassword = hashPassword(
        requestData['password'] as String,
      );

      final userCollection = mongoDbService.database.collection('users');
      final foundUser = await userCollection.findOne({
        'email': email,
      });

      if (foundUser != null) {
        return Response.json(
          statusCode: 400,
          body: {
            'status': 400,
            'message': 'A user with the provided email already exists',
            'error': 'user_exists',
          },
        );
      }

      // validate password regex
      if (!RegExp(r'^[a-zA-Z0-9!@#$%^&*)(+=._-]{6,}$').hasMatch(password)) {
        return Response.json(
          statusCode: 400,
          body: {
            'status': 400,
            'message': 'Password must contain at least 6 characters',
            'error': 'invalid_password',
          },
        );
      }

      // validate name (min 3 characters)
      if (name.length < 3) {
        return Response.json(
          statusCode: 400,
          body: {
            'status': 400,
            'message': 'Name must contain at least 3 characters',
            'error': 'invalid_name',
          },
        );
      }

      final x = await userCollection.insertOne({
        'email': requestData['email'],
        'password': hashedPassword,
        'name': requestData['name'],
        'userType': userType.name,
        'age': requestData['age'],
        'username': requestData['username'],
        'followingsCount': 0,
        'followersCount': 0,
      });

      print('writeResult: ${x.id}');

      final createdUser = await userRepository.getQuery(
        UserQuery.id,
        toObjectId(x.id).oid,
      );

      return Response.json(
        body: {
          'status': 200,
          'message': 'User registered successfully',
          'user': createdUser,
        },
      );
    } else {
      return Response.json(
        statusCode: 404,
        body: {
          'status': 404,
          'message': 'Unsupported request method: ${request.method}',
        },
      );
    }
  } catch (e) {
    return Response.json(
      statusCode: 400,
      body: {
        'message': 'Check the request body and try again',
        'error': e.toString(),
      },
    );
  }
}

UserType _getUserTypeFromString(String typeString) {
  final normalizedString = typeString.toLowerCase();
  return UserType.values.firstWhere(
    (type) => type.name.toLowerCase() == normalizedString,
    orElse: () => UserType.user,
  );
}
