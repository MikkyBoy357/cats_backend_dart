import 'package:cats_backend/helpers/helpers.dart';
import 'package:cats_backend/services/mongo_service.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart' as shelf;

Handler middleware(Handler handler) {
  mongoDbPoolService.releaseAll();
  return handler.use(requestLogger()).use(mongoinitialization()).use(
        fromShelfMiddleware(
          shelf.corsHeaders(
            headers: {
              shelf.ACCESS_CONTROL_ALLOW_ORIGIN: '*',
            },
          ),
        ),
      );
}
