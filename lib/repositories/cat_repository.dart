import 'package:cats_backend/models/models.dart';

List<Cat> cats = [
  const Cat(id: 1, name: 'Fluffy'),
  const Cat(id: 2, name: 'Whiskers'),
  const Cat(id: 3, name: 'Tom'),
];

class CatRepository {
  List<Cat> getCats() => cats;

  Cat? getCatById(int id) {
    try {
      return cats.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  Cat addCat({required String name}) {
    final cat = Cat(
      id: cats.length + 1,
      name: name,
    );

    cats.add(cat);
    return cat;
  }

  Cat updateCat({required int id, required String name}) {
    final index = cats.indexWhere((cat) => cat.id == id);
    final newCat = Cat(
      id: id,
      name: name,
    );

    cats[index] = newCat;
    return newCat;
  }

  bool deleteCat(int id) {
    if (cats.any((cat) => cat.id == id)) {
      cats.removeWhere((cat) => cat.id == id);
      return true;
    } else {
      return false;
    }
  }
}
