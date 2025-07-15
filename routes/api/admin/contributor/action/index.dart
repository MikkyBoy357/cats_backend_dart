import 'dart:convert';
import 'dart:math';

import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/helpers/helpers.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  final userRepository = UserRepository(
    database: await mongoDbPoolService.acquire(),
  );

  try {
    final request = context.request;
    final authValidationResponse = context.read<AuthValidationResponse>();
    final saint = authValidationResponse.user!;
    if (request.method == HttpMethod.post) {
      // await mongoDbService.open();

      if (saint.userType != UserType.admin) {
        return Response.json(
          statusCode: 403,
          body: {
            'status': 403,
            'message': 'Only admins can create contributor accounts',
            'error': 'unauthorized_action',
          },
        );
      }

      // Parse request data
      final requestBody = await request.body();
      final requestData = jsonDecode(requestBody) as Map<String, dynamic>;

      // Extract required fields
      final name = requestData['name'] as String;

      // Validate name (min 3 characters)
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

      // Generate a username (not using email as identifier)
      final username = generateUsername(name);

      // Check if username exists
      final userCollection =
          (await mongoDbPoolService.acquire()).collection('users');
      final existingUsername = await userCollection.findOne({
        'username': username,
      });

      var finalUsername = username;
      if (existingUsername != null) {
        // If username exists, generate a new one with a random suffix
        final modifiedUsername = '$username${Random().nextInt(999)}';

        // Check if the modified username exists
        final existingModifiedUsername = await userCollection.findOne({
          'username': modifiedUsername,
        });

        if (existingModifiedUsername != null) {
          return Response.json(
            statusCode: 400,
            body: {
              'status': 400,
              'message':
                  'Failed to generate unique username. Please try again.',
              'error': 'username_generation_failed',
            },
          );
        }

        finalUsername = modifiedUsername;
      }

      // Generate password based on username
      final password = generatePasswordFromUsername(finalUsername);
      final hashedPassword = hashPassword(password);

      // Create the contributor account
      final userData = {
        'password': hashedPassword,
        'name': name,
        'username': finalUsername,
        'userType': UserType.contributor.name,
        'followingsCount': 0,
        'followersCount': 0,
        'isOnline': false,
        'lastSeen': DateTime.now().toString(),
        'createdBy': saint.$_id,
      };

      final result = await userCollection.insertOne(userData);

      final createdUser = await userRepository.getQuery(
        UserQuery.id,
        toObjectId(result.id).oid,
      );

      return Response.json(
        body: {
          'status': 200,
          'message': 'Contributor account created successfully',
          'user': createdUser,
          'credentials': {
            'username': finalUsername,
            'password': password,
          },
        },
      );
    } else if (request.method == HttpMethod.get) {
      // await mongoDbService.open();

      // Check if user is admin
      if (saint.userType != UserType.admin) {
        return Response.json(
          statusCode: 403,
          body: {
            'status': 403,
            'message': 'Only admins can view their contributors',
            'error': 'unauthorized_action',
          },
        );
      }

      // Get contributors created by this admin
      final userCollection =
          (await mongoDbPoolService.acquire()).collection('users');
      final contributors = await userCollection.find({
        'userType': UserType.contributor.name,
        'createdBy': saint.$_id,
      }).toList();

      // Transform MongoDB documents to User objects
      final contributorsList = contributors.map((doc) {
        return User.fromJson(doc).toJson();
      }).toList();

      return Response.json(
        body: {
          'status': 200,
          'message': 'Contributors retrieved successfully',
          'contributors': contributorsList,
          'count': contributorsList.length,
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
      statusCode: 500,
      body: {
        'status': 500,
        'message': 'Server error. Something went wrong',
        'error': e.toString(),
      },
    );
  }
}
