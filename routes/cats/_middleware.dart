import 'package:cats_backend/helpers/helpers.dart';
import 'package:cats_backend/repositories/repositories.dart';
import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) {
  return handler
      .use(requestLogger())
      .use(provider((_) => CatRepository()))
      .use(authorize());
}
