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
