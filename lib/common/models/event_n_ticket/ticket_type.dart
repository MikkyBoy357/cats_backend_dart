import 'package:mongo_dart/mongo_dart.dart';

class TicketType {
  ObjectId id;
  ObjectId eventId;
  double price;
  String name;
  String description;

  TicketType({
    required this.id,
    required this.eventId,
    required this.price,
    required this.name,
    required this.description,
  });

  factory TicketType.fromJson(Map<String, dynamic> json) {
    return TicketType(
      id: json['_id'] as ObjectId,
      eventId: json['eventId'] as ObjectId,
      price: json['price'] as double,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'eventId': eventId,
      'price': price,
      'name': name,
      'description': description,
    };
  }

  // sample data
  factory TicketType.sampleData() {
    return TicketType(
      id: ObjectId(),
      eventId: ObjectId(),
      price: 100,
      name: 'VIP',
      description: 'VIP ticket',
    );
  }
}

// Request

class TicketTypeRequest {
  String eventId;
  double price;
  String name;
  String description;

  TicketTypeRequest({
    required this.eventId,
    required this.price,
    required this.name,
    required this.description,
  });

  factory TicketTypeRequest.fromJson(Map<String, dynamic> json) {
    return TicketTypeRequest(
      eventId: json['eventId'].toString(),
      price: json['price'] as double,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'price': price,
      'name': name,
      'description': description,
    };
  }

  TicketType toTicketType() {
    return TicketType(
      id: ObjectId(),
      eventId: ObjectId.fromHexString(eventId),
      price: price,
      name: name,
      description: description,
    );
  }
}
