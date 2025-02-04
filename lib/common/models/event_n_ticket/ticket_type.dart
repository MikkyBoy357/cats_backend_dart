import 'package:cats_backend/common/common.dart';
import 'package:mongo_dart/mongo_dart.dart';

class TicketType {
  ObjectId id;
  num price;
  String name;
  String description;
  String codePrefix;

  TicketType({
    required this.id,
    required this.price,
    required this.name,
    required this.description,
    this.codePrefix = 'STR',
  });

  factory TicketType.fromJson(Map<String, dynamic> json) {
    return TicketType(
      id: toObjectId(json['_id']),
      price: json['price'] as num,
      name: json['name'] as String,
      description: json['description'] as String,
      codePrefix:
          json['codePrefix'] == null ? 'STR' : json['codePrefix'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'price': price,
      'name': name,
      'description': description,
      'codePrefix': codePrefix,
    };
  }

  // sample data
  factory TicketType.sampleData() {
    return TicketType(
      id: ObjectId(),
      price: 100,
      name: 'VIP',
      description: 'VIP ticket',
      codePrefix: 'VIP',
    );
  }
}

// Request

class TicketTypeRequest {
  num price;
  String name;
  String description;
  String codePrefix;

  TicketTypeRequest({
    required this.price,
    required this.name,
    required this.description,
    this.codePrefix = 'STR',
  });

  factory TicketTypeRequest.fromJson(Map<String, dynamic> json) {
    return TicketTypeRequest(
      price: json['price'] as num,
      name: json['name'] as String,
      description: json['description'] as String,
      codePrefix: json['codePrefix'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'price': price,
      'name': name,
      'description': description,
      'codePrefix': codePrefix,
    };
  }

  TicketType toTicketType() {
    return TicketType(
      id: ObjectId(),
      price: price,
      name: name,
      description: description,
      codePrefix: codePrefix,
    );
  }
}
