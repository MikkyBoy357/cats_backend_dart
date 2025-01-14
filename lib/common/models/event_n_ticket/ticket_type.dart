import 'package:mongo_dart/mongo_dart.dart';

class TicketType {
  ObjectId id;
  double price;
  String name;
  String description;

  TicketType({
    required this.id,
    required this.price,
    required this.name,
    required this.description,
  });

  factory TicketType.fromJson(Map<String, dynamic> json) {
    return TicketType(
      id: json['_id'] as ObjectId,
      price: json['price'] as double,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'price': price,
      'name': name,
      'description': description,
    };
  }

  // sample data
  factory TicketType.sampleData() {
    return TicketType(
      id: ObjectId(),
      price: 100,
      name: 'VIP',
      description: 'VIP ticket',
    );
  }
}

// Request

class TicketTypeRequest {
  double price;
  String name;
  String description;

  TicketTypeRequest({
    required this.price,
    required this.name,
    required this.description,
  });

  factory TicketTypeRequest.fromJson(Map<String, dynamic> json) {
    return TicketTypeRequest(
      price: json['price'] as double,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'price': price,
      'name': name,
      'description': description,
    };
  }

  TicketType toTicketType() {
    return TicketType(
      id: ObjectId(),
      price: price,
      name: name,
      description: description,
    );
  }
}
