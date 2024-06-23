import 'dart:convert';

import 'package:cats_backend/repositories/repositories.dart';
import 'package:cats_backend/services/mongo_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  final mongoService = await context.read<Future<MongoService>>();
  final isAuthenticated = context.read<bool>();

  if (!isAuthenticated) {
    return Response(body: 'Unauthenticated', statusCode: 401);
  }

  final catRepository = CatRepository(
    database: mongoService.database,
  );

  final request = context.request;
  final method = request.method;
  final queryParams = request.uri.queryParameters;

  if (method == HttpMethod.get) {
    final id = queryParams['id'];
    print('===> GET <==> Cats:');

    if (id != null) {
      final cat = await catRepository.getCatById(id);
      if (cat != null) {
        return Response.json(body: cat);
      }
      return Response.json(body: 'Cat not found', statusCode: 404);
    }

    final cats = await catRepository.getCats();
    return Response.json(body: cats);
  }

  if (method == HttpMethod.post) {
    final body = await request.body();
    final bodyJson = jsonDecode(body) as Map<String, dynamic>;

    final result = await catRepository.addCat(
      name: bodyJson['name'].toString(),
    );

    return Response.json(body: result, statusCode: 201);
  }

  if (method == HttpMethod.put) {
    final id = queryParams['id'];
    final body = await request.body();
    final bodyJson = jsonDecode(body) as Map<String, dynamic>;

    if (id != null) {
      print(id);
      final updatedCat = await catRepository.updateCat(
        id: id,
        name: bodyJson['name'].toString(),
      );

      if (updatedCat == null) {
        return Response.json(
          body: 'Cat not found. Cannot update',
          statusCode: 404,
        );
      }
      print('updatedCat: $updatedCat');
      return Response.json(body: updatedCat);
    }

    return Response.json(body: 'Cat not found', statusCode: 404);
  }

  if (method == HttpMethod.delete) {
    final id = queryParams['id'];
    if (id == null) {
      return Response.json(body: 'Missing id in query params', statusCode: 400);
    }

    final deletedCat = await catRepository.deleteCat(id);

    if (!deletedCat) {
      return Response.json(body: 'Cat not found', statusCode: 404);
    }

    return Response.json(body: 'Cat deleted successfully');
  }

  return Response(body: 'Unsupported request method: $method', statusCode: 405);
}
