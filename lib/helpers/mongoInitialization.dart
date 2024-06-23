import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';

Middleware mongoinitialization() {
  final mongoDbService = MongoService();

  return provider<Future<MongoService>>(
    (_) async {
      await mongoDbService.initializeMongo();
      return mongoDbService;
    },
  );
}
