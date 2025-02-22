import 'package:cats_backend/common/common.dart';
import 'package:mongo_dart/mongo_dart.dart';

class EventCategory {
  ObjectId id;
  String name;
  String description;
  String imageUrl;

  EventCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
  });

  factory EventCategory.fromJson(Map<String, dynamic> json) {
    return EventCategory(
      id: toObjectId(json['_id']),
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
    };
  }

  EventCategory copyWith({
    ObjectId? id,
    String? name,
    String? description,
    String? imageUrl,
  }) {
    return EventCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  factory EventCategory.sampleData() {
    return EventCategory(
      id: ObjectId(),
      name: 'Karaoke 🎙️',
      description: 'Sing your heart out!',
      imageUrl: 'https://picsum.photos/200',
    );
  }
}
