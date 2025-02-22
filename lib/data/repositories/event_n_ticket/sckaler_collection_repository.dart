import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/config/config.dart';
import 'package:dio/dio.dart';
import 'package:mongo_dart/mongo_dart.dart';

abstract class SckalerCollectionRepositoryImpl {
  // External API calls
  Future<PaymentTransactionResponse?> sckalerCollectionRequest({
    required PaymentTransaction paymentTransaction,
  });

  // Mongo DB
  Future<List<PaymentTransactionResponse>> getSckalerCollections();
  Future<PaymentTransactionResponse?> getSckalerCollectionById({
    required ObjectId sckalerCollectionId,
  });
  Future<PaymentTransactionResponse?> createSckalerCollection({
    required PaymentTransactionResponse sckalerCollectionRequest,
  });
}

class SckalerCollectionRepository implements SckalerCollectionRepositoryImpl {
  final Db _database;
  final Dio _dio = Dio();

  SckalerCollectionRepository({
    required Db database,
  }) : _database = database;

  DbCollection get _sckalerCollectionsCollection =>
      _database.sckalerCollectionsCollection;

  // External API calls
  @override
  Future<PaymentTransactionResponse?> sckalerCollectionRequest({
    required PaymentTransaction paymentTransaction,
  }) async {
    printGreen('${Config.sckalerBaseUrl}/collection');
    try {
      final res = await _dio.post<Map<String, dynamic>?>(
        '${Config.sckalerBaseUrl}/collection',
        data: paymentTransaction.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer ${Config.sckalerApiKey}',
          },
        ),
      );

      printYellow('sckalerCollectionResponse: $res');
      final sckalerCollectionResponse =
          PaymentTransactionResponse.fromJson(res.data!);

      return sckalerCollectionResponse;
    } catch (e) {
      printRed('Error creating Sckaler Collection: $e');
      return null;
    }
  }

  // Mongo DB
  @override
  Future<List<PaymentTransactionResponse>> getSckalerCollections() async {
    final res = await _sckalerCollectionsCollection.find().toList();
    printGreen('Sckaler Collections: $res');

    final sckalerCollections =
        res.map((e) => PaymentTransactionResponse.fromJson(e)).toList();

    return sckalerCollections;
  }

  @override
  Future<PaymentTransactionResponse?> getSckalerCollectionById({
    required ObjectId sckalerCollectionId,
  }) async {
    final res = await _sckalerCollectionsCollection.findOne({
      '_id': sckalerCollectionId,
    });

    if (res == null) {
      return null;
    }

    final sckalerCollection = PaymentTransactionResponse.fromJson(res);

    return sckalerCollection;
  }

  @override
  Future<PaymentTransactionResponse?> createSckalerCollection({
    required PaymentTransactionResponse sckalerCollectionRequest,
  }) async {
    final result = await _sckalerCollectionsCollection.insertOne(
      sckalerCollectionRequest.toJson(),
    );
    printGreen('Create Sckaler Collection result: $result');

    if (result.writeError != null) {
      return null;
    }

    if (result.id is ObjectId) {
      final sckalerCollectionId = result.id as ObjectId;
      final sckalerCollection = await getSckalerCollectionById(
        sckalerCollectionId: sckalerCollectionId,
      );
      return sckalerCollection;
    }

    return null;
  }
}
