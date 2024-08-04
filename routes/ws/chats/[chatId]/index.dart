// routes/ws.dart
import 'package:cats_backend/helpers/authentication_validation.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';
import 'package:mongo_dart/mongo_dart.dart';

final clients = <WebSocketChannel>[];
final myEvents = <String>[
  'MESSAGE',
  'TYPING',
  'READ',
  'CONNECT',
];

Future<Response> onRequest(RequestContext context, String id) async {
  print('======= chatId =======> $id');
  final headers = context.request.headers;
  final token = headers['authorization'];

  final authValidationResponse = await getAuthResult(token: token);

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

    final headers = context.request.headers;
    print('Headers: $headers');

    clients.add(channel);
    channel.sink.add('Server: You are logged in as: @${saint.username}');
    for (final client in clients) {
      if (client != channel) {
        client.sink.add('User @${saint.username} connected');
      }
    }

    channel.stream.listen(
      (message) {
        print('Event: ${message.runtimeType}');
        print('Received message: $message');
        print('Protocol: $protocol');

        message.on('MESSAGE', (data) {
          print('Received ON message: $data');
        });

        channel.sink.add('echo => $message');

        for (final client in clients) {
          if (client != channel) {
            client.sink.add('User @${saint.username} says: $message');
          }
        }
      },
      onError: (dynamic error) {
        printRed('An error occurred: $error');
        channel.sink.close();
      },
      onDone: () {
        print('Server: Client disconnected');
        channel.sink.close();
      },
    );
  });

  return handler(context);
}

void printRed(String message) {
  print('\x1B[31m$message\x1B[0m');
}
