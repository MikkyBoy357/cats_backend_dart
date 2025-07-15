import 'dart:io';

import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/helpers/helpers.dart';
import 'package:cats_backend/services/services.dart';
import 'package:cats_backend/util/util.dart';
import 'package:dart_frog/dart_frog.dart';

Future<void> init(InternetAddress ip, int port) async {
  // Any code initialized within this method will only run on server start,any
  // hot reloads afterwards will not trigger this method until a hot restart.

  final ipAddress = await getPublicIpAddress();

  printBlue('Init -> IP: $ip, Port: $port');
  printGreen('URL: http://$ipAddress:$port');

  setupLocator();
  printMagenta('Initializing mongoDbPoolService...');
  await mongoDbPoolService.initialize();
  printGreen('mongoDbPoolService initialized ✅ ');

  // await mongoDbService.setupConnections();
  //
  // // Initialize the MongoDB service
  // await mongoDbService.initializeMongo();

  // Initialize the firebase
  await FirebaseService.initializeFirebase();
}

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) {
  return serve(handler, ip, port);
}
