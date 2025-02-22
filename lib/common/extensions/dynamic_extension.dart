import 'package:dartz/dartz.dart';
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

Either<ObjectId, T> parseEither<T>(
  dynamic value,
  T Function(Map<String, dynamic>) fromJson,
) {
  if (value is Map) {
    return Right(fromJson(value as Map<String, dynamic>));
  } else {
    return Left(toObjectId(value));
  }
}

List<Either<ObjectId, T>> parseEitherList<T>(
  List<dynamic> list,
  T Function(Map<String, dynamic>) fromJson,
) {
  return list.map((item) => parseEither<T>(item, fromJson)).toList();
}
