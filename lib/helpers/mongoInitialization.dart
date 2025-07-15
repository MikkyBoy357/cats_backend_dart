import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';

int requestCount = 0;
DateTime startTime = DateTime.now();
DateTime lastRequestTime = DateTime.now();

Middleware mongoinitialization() {
  requestCount++;
  printGreen('Request count: $requestCount');
  printMagenta('isConnected: ${mongoDbService.database.isConnected}');
  printMagenta('initialized: ${mongoDbService.isInitialized}');

  return (Handler handler) {
    return (context) async {
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
      } else {
        await mongoDbService.refreshDbConnection();
      }

      lastRequestTime = DateTime.now();

      final response = await handler(context);
      return response;
    };
  };
}
