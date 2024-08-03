import 'package:cats_backend/common/validator.dart';
import 'package:mongo_dart/mongo_dart.dart';

class User {
  ObjectId $_id;
  String name;
  String email;
  String? password;
  int age;
  String username;
  String? avatarUrl;
  String? bio;
  int? followingsCount;
  int? followersCount;

  User({
    required this.$_id,
    required this.name,
    required this.email,
    required this.password,
    required this.age,
    required this.username,
    this.avatarUrl,
    this.bio,
    required this.followingsCount,
    required this.followersCount,
  });

  User.fromJson(Map<String, dynamic> map)
      : $_id = map['_id'] as ObjectId,
        name = map['name'] as String? ?? '',
        email = map['email'] as String,
        password = map['password'] as String?,
        age = map['age'] as int? ?? 0,
        username = map['username'] as String? ?? '',
        avatarUrl = map['avatarUrl'] as String?,
        bio = map['bio'] as String?,
        followingsCount = map['followingsCount'] as int?,
        followersCount = map['followersCount'] as int?;

  Map<String, dynamic> toJson() {
    return {
      '_id': $_id,
      'name': name,
      'email': email,
      'password': password,
      'age': age,
      'username': username,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'followingsCount': followingsCount,
      'followersCount': followersCount,
    };
  }

  User copyWith({
    ObjectId? $_id,
    String? name,
    String? email,
    String? password,
    int? age,
    String? username,
    String? avatarUrl,
    String? bio,
    int? followingsCount,
    int? followersCount,
  }) {
    return User(
      $_id: $_id ?? this.$_id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      age: age ?? this.age,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      followingsCount: followingsCount ?? this.followingsCount,
      followersCount: followersCount ?? this.followersCount,
    );
  }

  void validate() {
    Validator.validateRequiredString(name, fieldName: 'Name');
    Validator.validateEmail(email);
    Validator.validatePassword(password!);
    Validator.validateRequiredString(username, fieldName: 'Username');
  }
}
