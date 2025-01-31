import 'package:cats_backend/common/extensions/saint_lookup.dart';
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

    print('====> AggregationPipelineBuilder <====');
    print(pipeline.build());
    print('====> AggregationPipelineBuilder <====');

    final result = await aggregateToStream(pipeline.build()).toList();
    return result;
  }
}

class PopulateField {
  // The field in the document to be populated
  final String fieldName;
  // The name of the collection to fetch the data from
  final String collectionName;
  // Optional list of sub-fields to populate
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
      for (final populateField in fieldsToPopulate) {
        final foreignField = populateField.fieldName;
        final collectionName = populateField.collectionName;

        if (doc.containsKey(foreignField)) {
          final foreignId = doc[foreignField] as ObjectId;

          // Query the foreign collection
          final foreignCollection = db.collection(collectionName);
          final foreignDoc =
              await foreignCollection.findOne(where.id(foreignId));

          if (foreignDoc != null) {
            // If there are sub-fields to populate, populate them recursively
            if (populateField.subPopulateFields.isNotEmpty) {
              for (final subPopulateField in populateField.subPopulateFields) {
                final subForeignField = subPopulateField.fieldName;
                final subCollectionName = subPopulateField.collectionName;

                if (foreignDoc.containsKey(subForeignField)) {
                  final subForeignId = foreignDoc[subForeignField] as ObjectId;

                  // Query the sub-collection
                  final subForeignCollection = db.collection(subCollectionName);
                  final subForeignDoc = await subForeignCollection
                      .findOne(where.id(subForeignId));

                  if (subForeignDoc != null) {
                    // Replace the subForeignId with the populated document
                    foreignDoc[subForeignField] = subForeignDoc;
                  }
                }
              }
            }

            // Replace the foreignId with the populated document
            doc[foreignField] = foreignDoc;
          }
        }
      }
    }

    return doc;
  }

  /// Populate multiple fields from their respective
  /// collections using `PopulateField` class.
  Future<List<Map<String, dynamic>>> findAndPopulateRikky(
    List<PopulateField> fieldsToPopulate, // List of fields to populate
  ) async {
    final docs = await find().toList();

    // For each document, populate the fields as specified in `fieldsToPopulate`
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
    List<PopulateField> fieldsToPopulate, // List of fields to populate
    Future<dynamic>
        queryDocs, // Query that returns either a single doc or a list of docs
  ) async {
    final result = await queryDocs;

    // Normalize result to a list, even if it's a single document
    final docs = result is List
        ? result
            .cast<Map<String, dynamic>>() // Cast to List<Map<String, dynamic>>
        : <Map<String, dynamic>>[
            result as Map<String, dynamic>,
          ]; // Wrap single document in a list

    // Populate the fields for each document
    for (final doc in docs) {
      await _populateFieldsRecursively(doc, fieldsToPopulate);
    }

    // Always return a list of documents
    return docs;
  }

  /// Helper function to recursively populate fields
  Future<void> _populateFieldsRecursively(
    Map<String, dynamic> doc,
    List<PopulateField> fieldsToPopulate,
  ) async {
    for (final populateField in fieldsToPopulate) {
      final foreignField = populateField.fieldName;
      final collectionName = populateField.collectionName;

      if (doc.containsKey(foreignField)) {
        final foreignId = doc[foreignField] as ObjectId;

        // Query the foreign collection
        final foreignCollection = db.collection(collectionName);
        final foreignDoc = await foreignCollection.findOne(where.id(foreignId));

        if (foreignDoc != null) {
          // If there are sub-fields to populate, populate them recursively
          if (populateField.subPopulateFields.isNotEmpty) {
            await _populateFieldsRecursively(
              foreignDoc,
              populateField.subPopulateFields,
            );
          }

          // Replace the foreignId with the populated document
          doc[foreignField] = foreignDoc;
        }
      }
    }
  }
}
