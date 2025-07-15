// routes/api/admin/change_contributor_password.dart
import 'dart:async';
import 'dart:convert';

import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/helpers/helpers.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

Future<Response> onRequest(RequestContext context) async {
  // final userRepository = UserRepository(
  //   database: await mongoDbPoolService.acquire(),
  // );

  try {
    final request = context.request;
    final authValidationResponse = context.read<AuthValidationResponse>();
    final admin = authValidationResponse.user!;

    if (request.method != HttpMethod.post) {
      return Response.json(
        statusCode: 404,
        body: {
          'status': 404,
          'message': 'Unsupported request method: ${request.method}',
        },
      );
    }

    // await mongoDbService.open();

    // Only admins can access this endpoint
    if (admin.userType != UserType.admin) {
      return Response.json(
        statusCode: 403,
        body: {
          'status': 403,
          'message': 'Only admins can change contributor passwords',
          'error': 'unauthorized_action',
        },
      );
    }

    // Parse request data
    final requestBody = await request.body();
    final requestData = jsonDecode(requestBody) as Map<String, dynamic>;

    // Extract contributor ID and new password option
    final contributorUsername = requestData['name'] as String;
    final customPassword = requestData['password'] as String?;

    // Find the contributor
    final userCollection =
        (await mongoDbPoolService.acquire()).collection('users');
    final contributor = await userCollection.findOne({
      'name': contributorUsername,
      'userType': UserType.contributor.name,
    });

    if (contributor == null) {
      return Response.json(
        statusCode: 404,
        body: {
          'status': 404,
          'message': 'Contributor not found',
          'error': 'contributor_not_found',
        },
      );
    }

    // Generate or use custom password
    final String newPassword;
    if (customPassword != null && customPassword.isNotEmpty) {
      // Validate custom password
      if (!RegExp(r'^[a-zA-Z0-9!@#$%^&*)(+=._-]{6,}$')
          .hasMatch(customPassword)) {
        return Response.json(
          statusCode: 400,
          body: {
            'status': 400,
            'message': 'Password must contain at least 6 characters',
            'error': 'invalid_password',
          },
        );
      }
      newPassword = customPassword;
    } else {
      // Generate new password based on username
      newPassword = generatePasswordFromUsername(contributorUsername);
    }

    final hashedPassword = hashPassword(newPassword);

    // Update the password
    await userCollection.updateOne(
      where.eq('_id', contributor['_id']),
      {
        r'$set': {
          'password': hashedPassword,
        },
      },
    );

    return Response.json(
      body: {
        'status': 200,
        'message': 'Contributor password changed successfully',
        'credentials': {
          'username': contributorUsername,
          'password': newPassword,
        },
      },
    );
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
