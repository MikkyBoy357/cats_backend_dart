import 'dart:async';

import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String username) async {
  final userRepository = UserRepository(database: mongoDbService.database);
  final request = context.request;
  final method = request.method;
  final handler = UserRequestHandlerImpl(userRepository: userRepository);

  // get user by username
  final user = await userRepository.getQuery(UserQuery.username, username);
  print('======= wildcardUser ($username) =======> ${user?.toJson()}');

  if (user == null) {
    return Response(
      body: 'User not found',
      statusCode: 404,
    );
  }

  return switch (method) {
    HttpMethod.get => await handler.getUserFollowings(
        FollowedFollowerQuery.followerId,
        user.$_id.oid,
      ),
    _ => Response(
        body: 'Unsupported request method: $method',
        statusCode: 405,
      ),
  };
}
