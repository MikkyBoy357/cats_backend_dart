import 'dart:async';

import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String username) async {
  final userRepository = UserRepository(database: mongoDbService.database);
  final request = context.request;
  final method = request.method;
  final queryParams = request.uri.queryParameters;
  final handler = UserRequestHandlerImpl(userRepository: userRepository);

  // get user by username
  final passedUser = await userRepository.getQuery(
    UserQuery.username,
    username,
  );
  print('======= wildcardUser ($username) =======> ${passedUser?.toJson()}');

  if (passedUser == null) {
    return Response.json(
      body: 'User @$username not found',
      statusCode: 404,
    );
  }

  return switch (method) {
    HttpMethod.get => await handler.getUserFollowers(
        FollowedFollowerQuery.followedId,
        passedUser.$_id.oid,
      ),
    _ => Response(
        body: 'Unsupported request method: $method',
        statusCode: 405,
      ),
  };
}
