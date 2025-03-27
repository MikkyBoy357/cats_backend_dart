import 'package:cats_backend/common/common.dart';
import 'package:mongo_dart/mongo_dart.dart';

enum UserType {
  admin,
  contributor,
  user,
}

class User {
  ObjectId $_id;
  String name;
  String email;
  String? password;
  UserType userType;
  int age;
  String username;
  String? avatarUrl;
  String? bio;
  bool isOnline;
  DateTime lastSeen;
  int? followingsCount;
  int? followersCount;

  User({
    required this.$_id,
    required this.name,
    required this.email,
    required this.password,
    required this.userType,
    required this.age,
    required this.username,
    this.avatarUrl,
    this.bio,
    this.isOnline = false,
    required this.lastSeen,
    required this.followingsCount,
    required this.followersCount,
  });
  factory User.fromJson(Map<String, dynamic> json) {
    final userTypeString = json['userType'] as String?;
    return User(
      $_id: toObjectId(json['_id']),
      name: json['name'] as String? ?? '',
      email: json['email'] as String,
      password: json['password'] as String?,
      userType: userTypeString != null
          ? UserType.values.firstWhere(
              (type) => type.name.toLowerCase() == userTypeString.toLowerCase(),
              orElse: () => UserType.user,
            )
          : UserType.user,
      age: json['age'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String?,
      isOnline: json['isOnline'] as bool? ?? false,
      lastSeen: json['lastSeen'] != null
          ? DateTime.parse(json['lastSeen'].toString())
          : DateTime.now(),
      followingsCount: json['followingsCount'] as int?,
      followersCount: json['followersCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': $_id,
      'name': name,
      'email': email,
      'password': password,
      'userType': userType.name,
      'age': age,
      'username': username,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'isOnline': isOnline,
      'lastSeen': lastSeen.toString(),
      'followingsCount': followingsCount,
      'followersCount': followersCount,
    };
  }

  User copyWith({
    ObjectId? $_id,
    String? name,
    String? email,
    String? password,
    UserType? userType,
    int? age,
    String? username,
    String? avatarUrl,
    String? bio,
    bool? isOnline,
    DateTime? lastSeen,
    int? followingsCount,
    int? followersCount,
  }) {
    return User(
      $_id: $_id ?? this.$_id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      userType: userType ?? this.userType,
      age: age ?? this.age,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      followingsCount: followingsCount ?? this.followingsCount,
      followersCount: followersCount ?? this.followersCount,
    );
  }

  factory User.sampleData() {
    return User(
      $_id: ObjectId(),
      name: 'John Doe',
      email: 'johndoe@gmail.com',
      password: 'password',
      userType: UserType.user,
      age: 25,
      username: 'johndoe',
      avatarUrl: 'https://picsum.photos/200',
      bio: 'I am a software engineer',
      isOnline: true,
      lastSeen: DateTime.now(),
      followingsCount: 100,
      followersCount: 200,
    );
  }

  void validate() {
    Validator.validateRequiredString(name, fieldName: 'Name');
    Validator.validateEmail(email);
    Validator.validatePassword(password!);
    Validator.validateRequiredString(username, fieldName: 'Username');
  }
}
