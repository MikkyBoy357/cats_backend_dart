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
  final String fieldName; // The field in the document to be populated
  final String
      collectionName; // The name of the collection to fetch the data from

  PopulateField({
    required this.fieldName,
    required this.collectionName,
  });
}

class DbCollectionExt {
  final DbCollection collection;
  DbCollectionExt(this.collection);

  /// Populate multiple fields from their respective collections using `PopulateField` class.
  Future<List<Map<String, dynamic>>> findAndPopulate(
    List<PopulateField> fieldsToPopulate, // List of fields to populate
  ) async {
    final docs = await collection.find().toList();

    // For each document, populate the fields as specified in `fieldsToPopulate`
    for (final doc in docs) {
      for (final populateField in fieldsToPopulate) {
        final foreignField = populateField.fieldName;
        final collectionName = populateField.collectionName;

        if (doc.containsKey(foreignField)) {
          final foreignId = doc[foreignField] as ObjectId;

          // Query the foreign collection
          final foreignCollection = collection.db.collection(collectionName);
          final foreignDoc =
              await foreignCollection.findOne(where.id(foreignId));

          if (foreignDoc != null) {
            // Replace the foreignId with the populated document
            doc[foreignField] = foreignDoc;
          }
        }
      }
    }

    return docs;
  }
}
