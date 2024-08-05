import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/helpers/authentication_validation.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';
import 'package:mongo_dart/mongo_dart.dart';

final clients = <WebSocketChannel>[];

enum ChatEvent { message, typing, receipt, connect, disconnect }

Future<Response> onRequest(RequestContext context, String id) async {
  print('======= chatId =======> $id');
  final headers = context.request.headers;
  final queryParameters = context.request.uri.queryParameters;
  final token = headers['authorization'] ?? queryParameters['token'];

  final authValidationResponse = await getAuthResult(token: token);

  final profileRepository = ProfileRepository(
    database: mongoDbService.database,
  );

  final chatRepository = ChatRepository(
    database: mongoDbService.database,
  );

  if (!authValidationResponse.isValid) {
    return Response.json(
      statusCode: 401,
      body: 'Auth Error: ${authValidationResponse.errorMessage}',
    );
  }

  final saint = authValidationResponse.user!;

  final chatId = ObjectId.tryParse(id);
  if (chatId == null) {
    return Response.json(body: 'Error: Cannot Parse Invalid Chat ID.');
  }

  final handler = webSocketHandler((channel, protocol) {
    print('WebSocket connection established. Protocol: $protocol');

    profileRepository.changeOnlineStatus(
      user: saint,
      isOnline: true,
    );

    final headers = context.request.headers;
    print('Headers: $headers');

    clients.add(channel);
    print('Concurrent clients: ${clients.length}');
    channel.sink.add('Server: You are logged in as: @${saint.username}');
    for (final client in clients) {
      if (client != channel) {
        client.sink.add('User @${saint.username} connected');
      }
    }

    channel.stream.listen(
      (message) {
        print('Received message: $message');

        final wsEventMessage = WsEventMessage.fromString(
          message.toString(),
        )?.copyWith(
          senderId: saint.$_id.oid,
        );
        if (wsEventMessage == null) {
          printRed('Error: Cannot parse message JSON');
          return;
        }

        channel.sink.add('SENT => $message');
        printGreen('User @${saint.username} says: \n$message');

        for (final client in clients) {
          if (client != channel) {
            client.sink.add(wsEventMessage.toString());
          }
        }

        if (wsEventMessage.eventType == WsEventType.receipt) {
          if (wsEventMessage.message == null) {
            printRed('Error: Receipt message is null');
            return;
          }

          if (wsEventMessage.message is! Map<String, dynamic>) {
            printYellow('Error: Receipt message is not a Map<String, dynamic>');
            return;
          }

          final myJson = wsEventMessage.message as Map<String, dynamic>;
          final receiptPayload = ReceiptPayload.fromJson(myJson);

          printGreen('Receipt: ${receiptPayload.toJson()}');

          // Implement message receipt logic here
          chatRepository.updateMessageReadReceipt(
            chatId: chatId,
            user: saint,
            receiptPayload: receiptPayload,
          );
        }
      },
      onError: (dynamic error) {
        printRed('Client: $error');
        profileRepository.changeOnlineStatus(
          user: saint,
          isOnline: false,
        );
        channel.sink.add({
          'eventType': ChatEvent.connect,
          'message': 'User @${saint.username} disconnected',
        });
        channel.sink.close();
      },
      onDone: () {
        printRed('User @${saint.username} disconnected');
        profileRepository.changeOnlineStatus(
          user: saint,
          isOnline: false,
        );
        channel.sink.add({
          'eventType': ChatEvent.connect,
          'message': 'User @${saint.username} disconnected',
        });
        clients.remove(channel);
        channel.sink.close();
      },
    );
  });

  return handler(context);
}
