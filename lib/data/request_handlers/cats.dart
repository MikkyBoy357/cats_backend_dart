import 'dart:convert';

import 'package:cats_backend/data/data.dart';
import 'package:dart_frog/dart_frog.dart';

abstract class CatRequestHandler {
  Future<Response> handleGet(
    Map<String, String> queryParams,
  );
  Future<Response> handlePost(Request request);
  Future<Response> handlePut(
    Map<String, String> queryParams,
    Request request,
  );
  Future<Response> handleDelete(
    Map<String, String> queryParams,
  );
}

class CatRequestHandlerImpl implements CatRequestHandler {
  final CatRepository _catRepository;

  const CatRequestHandlerImpl({
    required CatRepository catRepository,
  }) : _catRepository = catRepository;

  @override
  Future<Response> handleGet(
    Map<String, String> queryParams,
  ) async {
    final id = queryParams['id'];
    print('===> GET <==> Cats:');

    if (id != null) {
      final cat = await _catRepository.getCatById(id);
      if (cat != null) {
        return Response.json(body: cat);
      }
      return Response.json(body: 'Cat not found', statusCode: 404);
    }

    final cats = await _catRepository.getCats();
    return Response.json(body: cats);
  }

  @override
  Future<Response> handlePost(
    Request request,
  ) async {
    final body = await request.body();
    final bodyJson = jsonDecode(body) as Map<String, dynamic>;

    final result =
        await _catRepository.addCat(name: bodyJson['name'].toString());
    return Response.json(body: result, statusCode: 201);
  }

  @override
  Future<Response> handlePut(
    Map<String, String> queryParams,
    Request request,
  ) async {
    final id = queryParams['id'];
    final body = await request.body();
    final bodyJson = jsonDecode(body) as Map<String, dynamic>;

    if (id != null) {
      print(id);
      final updatedCat = await _catRepository.updateCat(
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

  @override
  Future<Response> handleDelete(
    Map<String, String> queryParams,
  ) async {
    final id = queryParams['id'];
    if (id == null) {
      return Response.json(body: 'Missing id in query params', statusCode: 400);
    }

    final deletedCat = await _catRepository.deleteCat(id);
    if (!deletedCat) {
      return Response.json(body: 'Cat not found', statusCode: 404);
    }

    return Response.json(body: 'Cat deleted successfully');
  }
}
