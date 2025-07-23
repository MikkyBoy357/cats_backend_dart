import 'dart:io';

import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/helpers/helpers.dart';
import 'package:cats_backend/services/services.dart';
import 'package:cats_backend/util/util.dart';
import 'package:dart_frog/dart_frog.dart';

Future<void> init(InternetAddress ip, int port) async {
  // Any code initialized within this method will only run on server start,
  // any hot reloads afterwards will not trigger this method until a hot restart.

  final ipAddress = await getPublicIpAddress();

  printBlue('Init -> IP: $ip, Port: $port');
  printGreen('URL: http://$ipAddress:$port');

  setupLocator();
  // we don't await this so that the server can start immediately
  mongoDbPoolService.initialize();

  // Initialize Firebase
  await FirebaseService.initializeFirebase();
}

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) {
  // Always use the PORT from environment when available (required for Globe)
  final envPort = int.tryParse(Platform.environment['PORT'] ?? '') ?? port;

  // Use anyIPv6 for hosting compatibility
  final serverIp = InternetAddress.anyIPv6;

  printGreen('Server starting on: ${serverIp.address}:$envPort');

  return serve(handler, serverIp, envPort);
}
