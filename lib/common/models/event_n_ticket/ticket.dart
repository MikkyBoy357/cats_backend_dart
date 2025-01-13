import 'package:cats_backend/common/common.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Ticket {
  final ObjectId id;
  final ObjectId ticketTypeId;
  final TicketType ticketType;
  final ObjectId eventId;
  final String name;
  final double price;
  final TicketOwner owner;
  final DateTime dateIssued;

  Ticket({
    required this.id,
    required this.ticketTypeId,
    required this.ticketType,
    required this.eventId,
    required this.name,
    required this.price,
    required this.owner,
    required this.dateIssued,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['_id'] as ObjectId,
      ticketTypeId: json['ticketTypeId'] as ObjectId,
      ticketType:
          TicketType.fromJson(json['ticketType'] as Map<String, dynamic>),
      eventId: json['eventId'] as ObjectId,
      name: json['name'] as String,
      price: json['price'] as double,
      owner: TicketOwner.fromJson(json['owner'] as Map<String, dynamic>),
      dateIssued: json['dateIssued'] as DateTime,
    );
  }
}
