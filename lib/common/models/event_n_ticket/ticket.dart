import 'package:cats_backend/common/common.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Ticket {
  ObjectId id;
  Event event;
  TicketType ticketType;
  TicketOwner issuedTo;
  DateTime issuedAt;
  String ticketNumber;

  Ticket({
    required this.id,
    required this.event,
    required this.ticketType,
    required this.issuedTo,
    required this.issuedAt,
    required this.ticketNumber,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['_id'] as ObjectId,
      event: Event.fromJson(json['event'] as Map<String, dynamic>),
      ticketType: TicketType.fromJson(
        json['ticketType'] as Map<String, dynamic>,
      ),
      issuedTo: TicketOwner.fromJson(json['issuedTo'] as Map<String, dynamic>),
      issuedAt: json['issuedAt'] != null
          ? DateTime.parse(json['issuedAt'] as String)
          : DateTime.now(),
      ticketNumber: json['ticketNumber'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'event': event.toJson(),
      'ticketType': ticketType.toJson(),
      'issuedTo': issuedTo.toJson(),
      'issuedAt': issuedAt.toString(),
      'ticketNumber': ticketNumber,
    };
  }
}

class TicketRequest {
  ObjectId event;
  ObjectId ticketType;
  TicketOwner issuedTo;
  DateTime issuedAt;
  String ticketNumber;

  TicketRequest({
    required this.event,
    required this.ticketType,
    required this.issuedTo,
    required this.issuedAt,
    required this.ticketNumber,
  });

  factory TicketRequest.fromJson(Map<String, dynamic> json) {
    return TicketRequest(
      event: ObjectId.parse(json['event'] as String),
      ticketType: ObjectId.parse(json['ticketType'] as String),
      issuedTo: TicketOwner.fromJson(json['issuedTo'] as Map<String, dynamic>),
      issuedAt: json['issuedAt'] != null
          ? DateTime.parse(json['issuedAt'] as String)
          : DateTime.now(),
      ticketNumber: json['ticketNumber'] == null
          ? 'STR-00000000'
          : json['ticketNumber'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event': event,
      'ticketType': ticketType,
      'issuedTo': issuedTo.toJson(),
      'issuedAt': issuedAt.toString(),
      'ticketNumber': ticketNumber,
    };
  }

  TicketRequest copyWith({
    ObjectId? event,
    ObjectId? ticketType,
    TicketOwner? issuedTo,
    DateTime? issuedAt,
    String? ticketNumber,
  }) {
    return TicketRequest(
      event: event ?? this.event,
      ticketType: ticketType ?? this.ticketType,
      issuedTo: issuedTo ?? this.issuedTo,
      issuedAt: issuedAt ?? this.issuedAt,
      ticketNumber: ticketNumber ?? this.ticketNumber,
    );
  }
}
