import 'package:mongo_dart/mongo_dart.dart';

class User {
  ObjectId $_id;
  String name;
  String email;
  String password;
  int age;

  User({
    required this.$_id,
    required this.name,
    required this.email,
    required this.password,
    required this.age,
  });

  User.fromMap(Map<String, dynamic> map)
      : $_id = map['_id'] as ObjectId,
        name = map['name'] as String? ?? '',
        email = map['email'] as String,
        password = map['password'] as String,
        age = map['age'] as int? ?? 0;

  Map<String, dynamic> toMap() {
    return {
      '_id': $_id,
      'name': name,
      'email': email,
      'password': password,
      'age': age,
    };
  }

  User copyWith({
    ObjectId? $_id,
    String? name,
    String? email,
    String? password,
    int? age,
  }) {
    return User(
      $_id: $_id ?? this.$_id,
      name: name ?? '',
      email: email ?? '',
      password: password ?? '',
      age: age ?? 0,
    );
  }
}
