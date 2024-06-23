import 'dart:async';
import 'dart:convert';

import 'package:cats_backend/helpers/helpers.dart';
import 'package:cats_backend/models/models.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  try {
    final request = context.request;
    final mongoService = await context.read<Future<MongoService>>();

    if (request.method == HttpMethod.post) {
      await mongoService.open();

      final requestBody = await request.body();
      final requestData = jsonDecode(requestBody) as Map<String, dynamic>;

      final user = User.fromMap(requestData);

      user.password = hashPassword(
        user.password,
      );

      final userCollection = mongoService.database.collection('users');
      final foundUser = await userCollection.findOne({'email': user.email});

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
      if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$')
          .hasMatch(user.password)) {
        return Response.json(
          statusCode: 400,
          body: {
            'status': 400,
            'message': 'Password must contain at least 8 characters, '
                'including at least one letter and one number',
            'error': 'invalid_password',
          },
        );
      }

      await userCollection.insertOne(user.toMap());
      await mongoService.close();
      return Response.json(
        body: {
          'status': 200,
          'message': 'User registered successfully',
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
