import 'package:cats_backend/common/common.dart';
import 'package:mongo_dart/mongo_dart.dart';

extension DbCollectionX on DbCollection {
  Future<List<Map<String, dynamic>>?> findAndPopulate(
    dynamic selector, {
    List<SaintLookup> lookups = const [],
  }) async {
    final pipeline = AggregationPipelineBuilder()
      ..addStage(
        Match(selector),
      );

    for (final lookup in lookups) {
      pipeline
          .addStage(
            lookup.toMongoLookup(),
          )
          .addStage(
            /// [Project] to exclude the password field from the nested map
            /// 0 means exclude, 1 means include
            Project({
              '_id': 0,
              lookup.as: {
                'password': 0,
              },
            }),
          );

      /// merge all the [lookup.as] fields into a single array
      pipeline.addStage(
        Unwind(Field(lookup.as)),
      );
    }

    printBlue('====> AggregationPipelineBuilder <====');
    printMagenta(pipeline.build());
    printBlue('====> AggregationPipelineBuilder <====');

    final result = await aggregateToStream(pipeline.build()).toList();
    return result;
  }
}

class PopulateField {
  final String fieldName;
  final String collectionName;
  final List<PopulateField> subPopulateFields;

  PopulateField({
    required this.fieldName,
    required this.collectionName,
    this.subPopulateFields = const [],
  });
}

extension DbCollectionExtension on DbCollection {
  Future<Map<String, dynamic>?> findOneAndPopulateRikky(
    dynamic selector, {
    List<PopulateField> fieldsToPopulate = const [],
  }) async {
    final doc = await findOne(selector);

    if (doc != null) {
      await _populateFieldsRecursively(doc, fieldsToPopulate);
    }

    return doc;
  }

  /// Populate multiple fields from their respective
  /// collections using `PopulateField` class.
  Future<List<Map<String, dynamic>>> findAndPopulateRikky(
    List<PopulateField> fieldsToPopulate, {
    int page = 1,
    int limit = 20,
  }) async {
    final skip = (page - 1) * limit;
    final docs = await find(
      where.sortBy('createdAt').skip(skip).limit(limit),
    ).toList();

    for (final doc in docs) {
      await _populateFieldsRecursively(doc, fieldsToPopulate);
    }

    return docs;
  }

  /// This is another approach where you can pass in the
  /// Query docs, then populate the fields as specified in `fieldsToPopulate`
  /// Populate fields for documents retrieved from the collection.
  /// It supports both multiple documents (find) and a single document (findOne)
  Future<List<Map<String, dynamic>>> findAndPopulateLol(
    List<PopulateField> fieldsToPopulate,
    Future<dynamic> queryDocs,
  ) async {
    final result = await queryDocs;

    final docs = result is List
        ? result.cast<Map<String, dynamic>>()
        : <Map<String, dynamic>>[result as Map<String, dynamic>];

    for (final doc in docs) {
      await _populateFieldsRecursively(doc, fieldsToPopulate);
    }

    return docs;
  }

  Future<void> _populateFieldsRecursively(
    Map<String, dynamic> doc,
    List<PopulateField> fieldsToPopulate,
  ) async {
    for (final populateField in fieldsToPopulate) {
      final foreignField = populateField.fieldName;
      final collectionName = populateField.collectionName;

      if (doc.containsKey(foreignField)) {
        final foreignValue = doc[foreignField];

        if (foreignValue is ObjectId) {
          await _populateSingleField(
            doc,
            foreignField,
            collectionName,
            populateField.subPopulateFields,
          );
        } else if (foreignValue is List) {
          await _populateListField(
            doc,
            foreignField,
            collectionName,
            populateField.subPopulateFields,
          );
        }
      }
    }
  }

  Future<void> _populateSingleField(
    Map<String, dynamic> doc,
    String foreignField,
    String collectionName,
    List<PopulateField> subPopulateFields,
  ) async {
    final foreignId = doc[foreignField] as ObjectId;
    final foreignCollection = db.collection(collectionName);
    final foreignDoc = await foreignCollection.findOne(where.id(foreignId));

    if (foreignDoc != null) {
      if (subPopulateFields.isNotEmpty) {
        await _populateFieldsRecursively(foreignDoc, subPopulateFields);
      }
      doc[foreignField] = foreignDoc;
    }
  }

  Future<void> _populateListField(
    Map<String, dynamic> doc,
    String foreignField,
    String collectionName,
    List<PopulateField> subPopulateFields,
  ) async {
    final foreignIds = doc[foreignField] as List;
    final foreignCollection = db.collection(collectionName);
    final populatedList = <Map<String, dynamic>>[];

    for (final foreignId in foreignIds) {
      if (foreignId is ObjectId) {
        final foreignDoc = await foreignCollection.findOne(where.id(foreignId));
        if (foreignDoc != null) {
          if (subPopulateFields.isNotEmpty) {
            await _populateFieldsRecursively(foreignDoc, subPopulateFields);
          }
          populatedList.add(foreignDoc);
        }
      }
    }

    doc[foreignField] = populatedList;
  }
}
