import 'dart:convert';

import 'package:cats_backend/repositories/repositories.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  final isAuthenticated = context.read<bool>();

  if (!isAuthenticated) {
    return Response(body: 'Unauthenticated', statusCode: 401);
  }

  final repository = context.read<CatRepository>();
  final request = context.request;
  final method = request.method;
  final queryParams = request.uri.queryParameters;

  if (method == HttpMethod.get) {
    final id = int.tryParse(queryParams['id'] ?? '');

    if (id != null) {
      final cat = repository.getCatById(id);
      if (cat != null) {
        return Response.json(body: cat);
      }
      return Response(body: 'Cat not found', statusCode: 404);
    }

    final cats = repository.getCats();
    return Response.json(body: cats);
  }

  if (method == HttpMethod.post) {
    final body = await request.body();
    final bodyJson = jsonDecode(body) as Map<String, dynamic>;

    final result = repository.addCat(
      name: bodyJson['name'].toString(),
    );

    return Response.json(body: result, statusCode: 201);
  }

  if (method == HttpMethod.put) {
    final id = int.tryParse(queryParams['id'] ?? '');
    final body = await request.body();
    final bodyJson = jsonDecode(body) as Map<String, dynamic>;

    if (id != null) {
      final updatedCat = repository.updateCat(
        id: id,
        name: bodyJson['name'].toString(),
      );
      return Response.json(body: updatedCat);
    }

    return Response.json(body: 'Cat not found', statusCode: 404);
  }

  if (method == HttpMethod.delete) {
    final id = int.parse(queryParams['id']!);
    final success = repository.deleteCat(id);

    if (success) {
      return Response.json(body: 'Cat deleted successfully');
    }

    return Response.json(body: 'Cat not found', statusCode: 404);
  }

  return Response(body: 'Unsupported request method: $method', statusCode: 405);
}
