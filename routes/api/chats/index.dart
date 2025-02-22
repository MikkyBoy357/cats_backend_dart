import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/helpers/helpers.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  final authValidationResponse = context.read<AuthValidationResponse>();

  if (!authValidationResponse.isValid) {
    return Response.json(
      statusCode: 401,
      body: 'Auth Error: ${authValidationResponse.errorMessage}',
    );
  }

  final saint = authValidationResponse.user!;

  final chatRepository = ChatRepository(database: mongoDbService.database);
  final request = context.request;
  final method = request.method;
  final handler = ChatRequestHandlerImpl(chatRepository: chatRepository);

  return switch (method) {
    HttpMethod.get => handler.handleGetAllSaintChats(saintId: saint.$_id),
    _ => Future.value(
        Response(body: 'Unsupported request method: $method', statusCode: 405),
      ),
  };
}
