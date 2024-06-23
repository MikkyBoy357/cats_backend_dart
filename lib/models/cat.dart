class Cat {
  const Cat({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  Cat copyWith({
    int? id,
    String? name,
  }) {
    return Cat(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Cat.fromJson(Map<String, dynamic> json) {
    return Cat(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  @override
  String toString() {
    return '{id: $id, name: $name}';
  }
}
