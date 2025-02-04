import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';

Middleware mongoinitialization() {
  return provider<Future<MongoService>>(
    (_) async {
      if (!mongoDbService.isInitialized) {
        final stopwatch1 = Stopwatch()..start();
        await mongoDbService.initializeMongo();
        stopwatch1.stop();
        printGreen(
          'mongoDbService.initializeMongo() executed in '
          '====> ${stopwatch1.elapsed}',
        );
        final stopwatch = Stopwatch()..start();
        await mongoDbService.open();
        stopwatch.stop();
        printGreen(
          'mongoDbService.open() executed in ====> ${stopwatch.elapsed}',
        );
      }

      return mongoDbService;
    },
  );
}
