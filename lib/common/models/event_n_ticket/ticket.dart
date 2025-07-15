import 'package:cats_backend/common/common.dart';
import 'package:dartz/dartz.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Ticket {
  ObjectId id;
  Either<ObjectId, Event> event;
  Either<ObjectId, TicketType> ticketType;
  TicketOwner issuedTo;
  DateTime issuedAt;
  String ticketNumber;
  bool isScanned;
  DateTime? scannedAt;
  Either<ObjectId, User>? scannedBy;

  Ticket({
    required this.id,
    required this.event,
    required this.ticketType,
    required this.issuedTo,
    required this.issuedAt,
    required this.ticketNumber,
    this.isScanned = false,
    this.scannedAt,
    this.scannedBy,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: toObjectId(json['_id']),
      event: parseEither<Event>(json['event'], Event.fromJson),
      ticketType:
          parseEither<TicketType>(json['ticketType'], TicketType.fromJson),
      issuedTo: TicketOwner.fromJson(json['issuedTo'] as Map<String, dynamic>),
      issuedAt: json['issuedAt'] != null
          ? DateTime.parse(json['issuedAt'] as String)
          : DateTime.now(),
      ticketNumber: json['ticketNumber'] as String,
      isScanned: json['isScanned'] as bool? ?? false,
      scannedAt: json['scannedAt'] != null
          ? DateTime.parse(json['scannedAt'] as String)
          : null,
      scannedBy: json['scannedBy'] != null
          ? parseEither<User>(json['scannedBy'], User.fromJson)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'event': event.fold((l) => l, (r) => r),
      'ticketType': ticketType.fold((l) => l, (r) => r),
      'issuedTo': issuedTo.toJson(),
      'issuedAt': issuedAt.toString(),
      'ticketNumber': ticketNumber,
      'isScanned': isScanned,
      'scannedAt': scannedAt?.toString(),
      'scannedBy': scannedBy?.fold((l) => l, (r) => r.toJson()),
    };
  }

  Ticket copyWith({
    ObjectId? id,
    Either<ObjectId, Event>? event,
    Either<ObjectId, TicketType>? ticketType,
    TicketOwner? issuedTo,
    DateTime? issuedAt,
    String? ticketNumber,
    bool? isScanned,
    DateTime? scannedAt,
    Either<ObjectId, User>? scannedBy,
  }) {
    return Ticket(
      id: id ?? this.id,
      event: event ?? this.event,
      ticketType: ticketType ?? this.ticketType,
      issuedTo: issuedTo ?? this.issuedTo,
      issuedAt: issuedAt ?? this.issuedAt,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      isScanned: isScanned ?? this.isScanned,
      scannedAt: scannedAt ?? this.scannedAt,
      scannedBy: scannedBy ?? this.scannedBy,
    );
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

  factory TicketRequest.sampleData() {
    return TicketRequest(
      event: ObjectId(),
      ticketType: ObjectId(),
      issuedTo: TicketOwner.sampleData(),
      issuedAt: DateTime.now(),
      ticketNumber: 'STR-00000000',
    );
  }
}

class TicketBuyRequest {
  TicketRequest ticketRequest;
  PaymentTransaction paymentTransaction;

  TicketBuyRequest({
    required this.ticketRequest,
    required this.paymentTransaction,
  });

  factory TicketBuyRequest.fromJson(Map<String, dynamic> json) {
    return TicketBuyRequest(
      ticketRequest: TicketRequest.fromJson(
        json['ticketRequest'] as Map<String, dynamic>,
      ),
      paymentTransaction: PaymentTransaction.fromJson(
        json['paymentRequest'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticketRequest': ticketRequest.toJson(),
      'paymentRequest': paymentTransaction.toJson(),
    };
  }

  TicketBuyRequest copyWith({
    TicketRequest? ticketRequest,
    PaymentTransaction? paymentTransaction,
  }) {
    return TicketBuyRequest(
      ticketRequest: ticketRequest ?? this.ticketRequest,
      paymentTransaction: paymentTransaction ?? this.paymentTransaction,
    );
  }

  factory TicketBuyRequest.sampleData() {
    return TicketBuyRequest(
      ticketRequest: TicketRequest.sampleData(),
      paymentTransaction: PaymentTransaction.sampleData(),
    );
  }
}
