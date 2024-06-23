class User {
  // 1.
  String? id;
  String name;
  String email;
  String password;
  int age;

  // 2.
  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.age,
  });

  // 3.
  User.fromMap(Map<String, dynamic> map)
      : id = map['id'] as String? ?? '',
        name = map['name'] as String? ?? '',
        email = map['email'] as String,
        password = map['password'] as String,
        age = map['age'] as int? ?? 0;

  // 4.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'age': age,
    };
  }

  // 5.
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    int? age,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? '',
      email: email ?? '',
      password: password ?? '',
      age: age ?? 0,
    );
  }
}
