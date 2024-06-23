import 'package:cats_backend/models/models.dart';
import 'package:mongo_dart/mongo_dart.dart';

List<Cat> cats = [
  Cat($_id: ObjectId.fromSeconds(1), name: ''),
  Cat($_id: ObjectId.fromSeconds(2), name: 'Whiskers'),
  Cat($_id: ObjectId.fromSeconds(3), name: 'Tom'),
];

class CatRepository {
  final Db _database;

  CatRepository({
    required Db database,
  }) : _database = database;

  DbCollection get catsCollection => _database.collection('cats');

  Future<List<Cat>> getCats() async {
    final cats = await catsCollection.find().map((e) {
      return Cat.fromJson(e);
    }).toList();
    print('Cats: $cats');
    return cats;
  }

  Future<Cat?> getCatById(String id) async {
    final result = await catsCollection.findOne({
      '_id': ObjectId.fromHexString(id),
    });
    print('Rikky -> $result');

    if (result == null) {
      return null;
    }

    return Cat.fromJson(result);
  }

  Future<Cat?> addCat({required String name}) async {
    final result = await catsCollection.insertOne({'name': name});
    print('resultId: ${result.id}');

    if (result.writeError != null) {
      return null;
    }

    final cat = Cat(
      $_id: result.id as ObjectId,
      name: name,
    );
    return cat;
  }

  Future<Cat?> updateCat({required String id, required String name}) async {
    final result = await catsCollection.updateOne({
      '_id': ObjectId.fromHexString(id),
    }, {
      r'$set': {
        'name': name,
      },
    });

    if (result.writeError != null) {
      return null;
    }

    final updatedCat = Cat(
      $_id: ObjectId.fromHexString(id),
      name: name,
    );

    return updatedCat;
  }

  Future<bool> deleteCat(String id) async {
    print('=======> $id');
    final result = await catsCollection.remove({
      '_id': ObjectId.fromHexString(id),
    });

    if (result['n'] == 0) {
      return false;
    }

    return true;
  }
}
