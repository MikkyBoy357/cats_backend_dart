import 'dart:io';

import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';

Future<void> init(InternetAddress ip, int port) async {
  // Any code initialized within this method will only run on server start,any
  // hot reloads afterwards will not trigger this method until a hot restart.

  print('Init -> IP: $ip, Port: $port');

  // Initialize the MongoDB service
  await mongoDbService.initializeMongo();

  // Initialize the firebase
  await FirebaseService.initializeFirebase();
}

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) {
  // 1. Execute any custom code prior to starting the server...

  // 2. Use the provided `handler`, `ip`, and `port` to create a
  // custom `HttpServer`. Or use the Dart Frog serve method to do that for you.
  return serve(handler, ip, port);
}
