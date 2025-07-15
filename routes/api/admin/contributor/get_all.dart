// routes/api/admin/get_contributors.dart
import 'dart:async';

import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/helpers/helpers.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  try {
    final request = context.request;
    final authValidationResponse = context.read<AuthValidationResponse>();
    final saint = authValidationResponse.user!;

    if (request.method != HttpMethod.get) {
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
    if (saint.userType != UserType.admin) {
      return Response.json(
        statusCode: 403,
        body: {
          'status': 403,
          'message': 'Only admins can view contributors',
          'error': 'unauthorized_action',
        },
      );
    }

    // Get all contributors from the database
    final userCollection = mongoDbService.database.collection('users');
    final contributors = await userCollection
        .find({'userType': UserType.contributor.name})
        .map((doc) => {
              'id': toObjectId(doc['_id']).oid,
              'name': doc['name'] as String,
            })
        .toList();

    return Response.json(
      body: {
        'status': 200,
        'message': 'Contributors retrieved successfully',
        'contributors': contributors,
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
