import 'package:cats_backend/helpers/helpers.dart';
import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) {
  return handler.use(authorize());
}
