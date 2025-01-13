import 'package:cats_backend/common/common.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Event {
  ObjectId id;
  String name;
  String owner;
  String description;
  String location;
  DateTime date;
  List<String> categories;
  TicketType ticketType;

  Event({
    required this.id,
    required this.name,
    required this.owner,
    required this.description,
    required this.location,
    required this.date,
    required this.categories,
    required this.ticketType,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['_id'] as ObjectId,
      name: json['name'] as String,
      owner: json['owner'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      date: json['date'] != null
          ? DateTime.parse(json['date'].toString())
          : DateTime.now(),
      categories: (json['categories'] as List).map((e) => e as String).toList(),
      ticketType: TicketType.fromJson(
        json['ticketType'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'owner': owner,
      'description': description,
      'location': location,
      'date': date.toString(),
      'categories': categories.map((e) => e).toList(),
      'ticketType': ticketType.toJson(),
    };
  }
}
