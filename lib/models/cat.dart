import 'package:mongo_dart/mongo_dart.dart';

class Cat {
  const Cat({
    required this.$_id,
    required this.name,
  });

  final ObjectId $_id;
  final String name;

  Cat copyWith({
    ObjectId? $_id,
    String? name,
  }) {
    return Cat(
      $_id: $_id ?? this.$_id,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': $_id,
      'name': name,
    };
  }

  factory Cat.fromJson(Map<String, dynamic> json) {
    return Cat(
      $_id: json['_id'] as ObjectId,
      name: json['name'] as String,
    );
  }

  @override
  String toString() {
    return '{id: ${$_id}, name: $name}';
  }
}
