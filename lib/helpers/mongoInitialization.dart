import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';

Middleware mongoinitialization() {
  return provider<Future<MongoService>>(
    (_) async {
      if (!mongoDbService.isInitialized) {
        await mongoDbService.initializeMongo();
        await mongoDbService.open();
      }
      return mongoDbService;
    },
  );
}
