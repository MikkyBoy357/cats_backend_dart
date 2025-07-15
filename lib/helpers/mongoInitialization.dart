import 'package:cats_backend/common/common.dart';
import 'package:dart_frog/dart_frog.dart';

int requestCount = 0;
DateTime startTime = DateTime.now();
DateTime lastRequestTime = DateTime.now();

Middleware mongoinitialization() {
  requestCount++;
  printGreen('Request count: $requestCount');

  return (Handler handler) {
    return (context) async {
      lastRequestTime = DateTime.now();

      final response = await handler(context);
      return response;
    };
  };
}
