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
  bool soldOut;
  DateTime? validFrom; // The earliest date/time this ticket type can be scanned
  DateTime? validUntil; // The latest date/time this ticket type can be scanned
  int? maxScansPerDay; // Null means no daily limit.

  TicketType({
    required this.id,
    required this.price,
    required this.name,
    required this.description,
    this.totalSupply = 0,
    this.visibility = Visibility.public,
    this.codePrefix = 'STR',
    required this.createdBy,
    this.soldOut = false,
    this.validFrom,
    this.validUntil,
    this.maxScansPerDay,
  });

  factory TicketType.fromJson(Map<String, dynamic> json) {
    printMagenta('omo -> ${json}');
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
      soldOut: json['soldOut'] as bool? ?? false,
      validFrom: json['validFrom'] == null
          ? null
          : DateTime.tryParse(json['validFrom']),
      validUntil: json['validFrom'] == null
          ? null
          : DateTime.tryParse(json['validUntil']),
      maxScansPerDay:
          json['maxScansPerDay'] != null ? json['maxScansPerDay'] as int : null,
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
      'soldOut': soldOut,
      'validFrom': validFrom.toString(),
      'validUntil': validUntil.toString(),
      'maxScansPerDay': maxScansPerDay,
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
    bool? soldOut,
    DateTime? validFrom,
    DateTime? validUntil,
    int? maxScansPerDay,
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
      soldOut: soldOut ?? this.soldOut,
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
      maxScansPerDay: maxScansPerDay ?? this.maxScansPerDay,
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
      validFrom: DateTime.now(),
      validUntil: DateTime.now().add(Duration(days: 2)),
      maxScansPerDay: null,
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
  DateTime? validFrom; // The earliest date/time this ticket type can be scanned
  DateTime? validUntil; // The latest date/time this ticket type can be scanned
  int? maxScansPerDay; // Null means no daily limit.
  String? eventId;

  TicketTypeRequest({
    required this.price,
    required this.name,
    required this.description,
    this.totalSupply = 69,
    this.visibility = Visibility.public,
    this.codePrefix = 'STR',
    this.createdBy,
    this.validFrom,
    this.validUntil,
    this.maxScansPerDay,
    this.eventId,
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
      validFrom: json['validFrom'] == null
          ? null
          : DateTime.tryParse(
              json['validFrom'],
            ),
      validUntil: json['validFrom'] == null
          ? null
          : DateTime.tryParse(
              json['validUntil'],
            ),
      maxScansPerDay:
          json['maxScansPerDay'] != null ? json['maxScansPerDay'] as int : null,
      eventId: json['eventId'] as String?,
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
      'createdBy': createdBy?.oid,
      'validFrom': validFrom.toString(),
      'validUntil': validUntil.toString(),
      'maxScansPerDay': maxScansPerDay,
      'eventId': eventId,
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
      validFrom: validFrom,
      validUntil: validUntil,
      maxScansPerDay: maxScansPerDay,
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
    DateTime? validFrom,
    DateTime? validUntil,
    int? maxScansPerDay,
    String? eventId,
  }) {
    return TicketTypeRequest(
      price: price ?? this.price,
      name: name ?? this.name,
      description: description ?? this.description,
      totalSupply: totalSupply ?? this.totalSupply,
      visibility: visibility ?? this.visibility,
      codePrefix: codePrefix ?? this.codePrefix,
      createdBy: createdBy ?? this.createdBy,
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
      maxScansPerDay: maxScansPerDay ?? this.maxScansPerDay,
      eventId: eventId ?? this.eventId,
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
  DateTime? validFrom;
  DateTime? validUntil;
  int? maxScansPerDay;

  TicketTypeResponse({
    required this.id,
    required this.price,
    required this.name,
    required this.description,
    this.totalSupply = 0,
    this.visibility = Visibility.public,
    this.codePrefix = 'STR',
    required this.createdBy,
    this.validFrom,
    this.validUntil,
    this.maxScansPerDay,
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
      validFrom: json['validFrom'] == null
          ? null
          : DateTime.tryParse(
              json['validFrom'],
            ),
      validUntil: json['validFrom'] == null
          ? null
          : DateTime.tryParse(
              json['validUntil'],
            ),
      maxScansPerDay:
          json['maxScansPerDay'] != null ? json['maxScansPerDay'] as int : null,
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
      'validFrom': validFrom?.toIso8601String(),
      'validUntil': validUntil?.toIso8601String(),
      'maxScansPerDay': maxScansPerDay,
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
    DateTime? validFrom,
    DateTime? validUntil,
    int? maxScansPerDay,
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
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
      maxScansPerDay: maxScansPerDay ?? this.maxScansPerDay,
    );
  }
}
