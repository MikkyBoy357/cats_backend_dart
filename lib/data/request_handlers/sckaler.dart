import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/data/data.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

abstract class SckalerRequestHandler {
  Future<Response> handleGetSckalerCollections();
  Future<Response> handleGetSckalerCollectionById({
    required ObjectId sckalerCollectionId,
  });
  Future<Response> handleSckalerCollection({
    required PaymentTransaction paymentTransaction,
  });
}

class SckalerRequestHandlerImpl implements SckalerRequestHandler {
  final SckalerCollectionRepository _sckalerCollectionRepository;

  const SckalerRequestHandlerImpl({
    required SckalerCollectionRepository sckalerCollectionRepository,
  }) : _sckalerCollectionRepository = sckalerCollectionRepository;

  @override
  Future<Response> handleGetSckalerCollections() async {
    final sckalerCollections =
        await _sckalerCollectionRepository.getSckalerCollections();

    return Response.json(
      body: sckalerCollections,
      statusCode: sckalerCollections.isNotEmpty ? 200 : 404,
    );
  }

  @override
  Future<Response> handleGetSckalerCollectionById({
    required ObjectId sckalerCollectionId,
  }) async {
    printGreen('===> GET <==> Sckaler Collection by ID: $sckalerCollectionId');

    final sckalerCollection = await _sckalerCollectionRepository
        .getSckalerCollectionById(sckalerCollectionId: sckalerCollectionId);

    if (sckalerCollection == null) {
      return Response.json(
        body: 'Sckaler Collection with ID `$sckalerCollectionId` not found',
        statusCode: 404,
      );
    }

    return Response.json(
      body: sckalerCollection,
    );
  }

  @override
  Future<Response> handleSckalerCollection({
    required PaymentTransaction paymentTransaction,
  }) async {
    printGreen('===> POST <==> Sckaler Collection:');

    // External API call
    final sckalerCollectionResponse =
        await _sckalerCollectionRepository.sckalerCollectionRequest(
      paymentTransaction: paymentTransaction,
    );

    if (sckalerCollectionResponse == null) {
      return Response.json(
        body: 'Failed to create Sckaler Collection',
        statusCode: 500,
      );
    }

    // save to DB
    final createdSckalerCollection =
        await _sckalerCollectionRepository.createSckalerCollection(
      sckalerCollectionRequest: sckalerCollectionResponse.copyWith(
        paymentTransactionBody: paymentTransaction,
      ),
    );

    if (createdSckalerCollection == null) {
      printRed('Failed to save Sckaler Collection to DB');
      return Response.json(
        body: 'Failed to save Sckaler Collection to DB',
        statusCode: 69,
      );
    }

    printYellow(createdSckalerCollection.status);
    printYellow((createdSckalerCollection.status == 'SUCCESS').toString());

    return Response.json(
      body: createdSckalerCollection,
      statusCode: createdSckalerCollection.status == 'SUCCESS' ? 201 : 400,
    );
  }
}
