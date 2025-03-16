import 'package:cats_backend/common/common.dart';
import 'package:dartz/dartz.dart';
import 'package:mongo_dart/mongo_dart.dart';

enum Visibility { public, private }

class TicketType {
  ObjectId id;
  num price;
  String name;
  String description;
  int totalSupply;
  Visibility visibility;
  String codePrefix;
  ObjectId createdBy;

  TicketType({
    required this.id,
    required this.price,
    required this.name,
    required this.description,
    this.totalSupply = 0,
    this.visibility = Visibility.public,
    this.codePrefix = 'STR',
    required this.createdBy,
  });

  factory TicketType.fromJson(Map<String, dynamic> json) {
    return TicketType(
      id: toObjectId(json['_id']),
      price: json['price'] as num,
      name: json['name'] as String,
      description: json['description'] as String,
      totalSupply: json['totalSupply'] as int? ?? 0,
      visibility: Visibility.values.firstWhere(
        (e) => e.name == json['visibility'],
        orElse: () => Visibility.public,
      ),
      codePrefix:
          json['codePrefix'] == null ? 'STR' : json['codePrefix'] as String,
      createdBy: toObjectId(json['createdBy']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'price': price,
      'name': name,
      'description': description,
      'totalSupply': totalSupply,
      'visibility': visibility.name,
      'codePrefix': codePrefix,
      'createdBy': createdBy,
    };
  }

  TicketType copyWith({
    ObjectId? id,
    num? price,
    String? name,
    String? description,
    int? totalSupply,
    Visibility? visibility,
    String? codePrefix,
    ObjectId? createdBy,
  }) {
    return TicketType(
      id: id ?? this.id,
      price: price ?? this.price,
      name: name ?? this.name,
      description: description ?? this.description,
      totalSupply: totalSupply ?? this.totalSupply,
      visibility: visibility ?? this.visibility,
      codePrefix: codePrefix ?? this.codePrefix,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  factory TicketType.sampleData() {
    return TicketType(
      id: ObjectId(),
      price: 100,
      name: 'General Admission',
      description: 'General Admission Ticket',
      totalSupply: 100,
      createdBy: ObjectId(),
    );
  }
}
// Request

class TicketTypeRequest {
  num price;
  String name;
  String description;
  int totalSupply;
  Visibility visibility;
  String codePrefix;
  ObjectId? createdBy;

  TicketTypeRequest({
    required this.price,
    required this.name,
    required this.description,
    this.totalSupply = 69,
    this.visibility = Visibility.public,
    this.codePrefix = 'STR',
    this.createdBy,
  });

  factory TicketTypeRequest.fromJson(Map<String, dynamic> json) {
    return TicketTypeRequest(
      price: json['price'] as num,
      name: json['name'] as String,
      description: json['description'] as String,
      totalSupply: json['totalSupply'] as int? ?? 10,
      visibility: Visibility.values.firstWhere(
        (e) => e.name == json['visibility'],
        orElse: () => Visibility.public,
      ),
      codePrefix: (json['codePrefix'] == null ||
              json['codePrefix'].toString().trim().isEmpty)
          ? 'STR'
          : json['codePrefix'] as String,
      createdBy: ObjectId.fromHexString(
        json['createdBy'] as String,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'price': price,
      'name': name,
      'description': description,
      'totalSupply': totalSupply,
      'visibility': visibility.name,
      'codePrefix': codePrefix,
      'createdBy': createdBy,
    };
  }

  TicketType toTicketType() {
    return TicketType(
      id: ObjectId(),
      price: price,
      name: name,
      description: description,
      totalSupply: totalSupply,
      visibility: visibility,
      codePrefix: codePrefix,
      createdBy: createdBy!,
    );
  }

  TicketTypeRequest copyWith({
    num? price,
    String? name,
    String? description,
    int? totalSupply,
    Visibility? visibility,
    String? codePrefix,
    ObjectId? createdBy,
  }) {
    return TicketTypeRequest(
      price: price ?? this.price,
      name: name ?? this.name,
      description: description ?? this.description,
      totalSupply: totalSupply ?? this.totalSupply,
      visibility: visibility ?? this.visibility,
      codePrefix: codePrefix ?? this.codePrefix,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}

class TicketTypeResponse {
  ObjectId id;
  num price;
  String name;
  String description;
  int totalSupply;
  Visibility visibility;
  String codePrefix;
  Either<ObjectId, User> createdBy;

  TicketTypeResponse({
    required this.id,
    required this.price,
    required this.name,
    required this.description,
    this.totalSupply = 0,
    this.visibility = Visibility.public,
    this.codePrefix = 'STR',
    required this.createdBy,
  });

  factory TicketTypeResponse.fromJson(Map<String, dynamic> json) {
    return TicketTypeResponse(
      id: toObjectId(json['_id']),
      price: json['price'] as num,
      name: json['name'] as String,
      description: json['description'] as String,
      totalSupply: json['totalSupply'] as int? ?? 0,
      visibility: Visibility.values.firstWhere(
        (e) => e.name == json['visibility'],
        orElse: () => Visibility.public,
      ),
      codePrefix:
          json['codePrefix'] == null ? 'STR' : json['codePrefix'] as String,
      createdBy: parseEither<User>(json['createdBy'], User.fromJson),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'price': price,
      'name': name,
      'description': description,
      'totalSupply': totalSupply,
      'visibility': visibility.name,
      'codePrefix': codePrefix,
      'createdBy': createdBy.fold((l) => l, (r) => r),
    };
  }

  TicketTypeResponse copyWith({
    ObjectId? id,
    num? price,
    String? name,
    String? description,
    int? totalSupply,
    Visibility? visibility,
    String? codePrefix,
    Either<ObjectId, User>? createdBy,
  }) {
    return TicketTypeResponse(
      id: id ?? this.id,
      price: price ?? this.price,
      name: name ?? this.name,
      description: description ?? this.description,
      totalSupply: totalSupply ?? this.totalSupply,
      visibility: visibility ?? this.visibility,
      codePrefix: codePrefix ?? this.codePrefix,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
