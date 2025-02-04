import 'package:mongo_dart/mongo_dart.dart';

ObjectId toObjectId(dynamic id) {
  if (id is ObjectId) {
    return id;
  } else if (id is String) {
    return ObjectId.fromHexString(id);
  } else {
    ObjectId.tryParse(id.toString());
    throw ArgumentError(
      'Invalid id type: ${id.runtimeType}, instead of ObjectId or String.',
    );
  }
}
