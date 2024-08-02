import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/helpers/helpers.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String username) async {
  print('======= username =======> $username');
  final authValidationResponse = context.read<AuthValidationResponse>();

  if (!authValidationResponse.isValid) {
    return Response.json(
      statusCode: 401,
      body: 'Auth Error: ${authValidationResponse.errorMessage}',
    );
  }

  final saint = authValidationResponse.user!;

  final userRepository = UserRepository(database: mongoDbService.database);
  final request = context.request;
  final method = request.method;

  final passedUser = await userRepository.getQuery(
    UserQuery.username,
    username,
  );

  if (passedUser == null) {
    return Response(
      body: 'User not found',
      statusCode: 404,
    );
  }

  final bussRepository = BussRepository(database: mongoDbService.database);
  final bussHandler = BussRequestHandlerImpl(bussRepository: bussRepository);

  return switch (method) {
    HttpMethod.get => await bussHandler.handleGetWalletById(passedUser.$_id),
    HttpMethod.post => await bussHandler.handleBussTransfer(
        senderId: saint.$_id,
        receiverId: passedUser.$_id,
        amount: 10,
        description: 'Buss Transfer',
      ),
    _ => Response(
        body: 'Unsupported request method: $method',
        statusCode: 405,
      ),
  };
}
