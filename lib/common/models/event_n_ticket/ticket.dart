import 'package:cats_backend/common/common.dart';
import 'package:dartz/dartz.dart';
import 'package:mongo_dart/mongo_dart.dart';

typedef CanBeScannedData = ({
  bool canScan,
  String message,
});

class ScanEntry {
  ObjectId? scannedBy;
  DateTime scannedAt;
  bool success; // True if scan was successful, false if it was an error
  String? message; // Message in case of error

  ScanEntry({
    this.scannedBy,
    required this.scannedAt,
    required this.success,
    this.message,
  });

  factory ScanEntry.fromJson(Map<String, dynamic> json) {
    return ScanEntry(
      scannedBy: json['scannedBy'] as ObjectId?,
      scannedAt: DateTime.parse(json['scannedAt'].toString()),
      success: bool.tryParse(json['success'].toString()) ?? false,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scannedBy': scannedBy,
      'scannedAt': scannedAt.toString(),
      'success': success,
      'message': message,
    };
  }
}

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
  List<ScanEntry> scanHistory;

  // COMBO
  String? comboTicketId;
  String? comboId;
  String? comboCardNumber;

  // Helper getter to determine if the ticket can currently be scanned
  CanBeScannedData get canBeScanned {
    // If the ticket is already marked as fully used, it cannot be scanned.
    // if (isUsed) {
    //   printRed('Ticket is already fully used. ❌');
    //   return false;
    // }

    final ticketTypeData = ticketType.fold(
      (l) => null, // If it's just an ObjectId, we can't get the rules here.
      (r) => r, // If the full TicketType object is embedded, use it.
    );

    print('omo -> $ticketTypeData');

    // If ticketTypeData is null, it means the TicketType object wasn't embedded
    // or couldn't be retrieved. This scenario needs to be handled by fetching
    // the TicketType from the database in the API layer, not within the model.
    if (ticketTypeData == null) {
      printRed('Ticket Type data is not available for validation. ❌ \n'
          'Ensure TicketType is eagerly loaded or fetched separately.');
      return (
        canScan: false,
        message: 'Ticket Type data is not available for validation. ❌ \n'
            'Ensure TicketType is eagerly loaded or fetched separately.',
      );
    }

    final now = DateTime.now();

    // --- 1. Check Date Validity Range ---
    final validFrom = ticketTypeData.validFrom;
    final validUntil = ticketTypeData.validUntil;

    // If validFrom is set and current time is before it, not valid.
    if (validFrom != null && now.isBefore(validFrom)) {
      printRed('Ticket is not yet valid. Valid from: ${validFrom.toLocal()} ❌');
      return (
        canScan: false,
        message:
            'Ticket is not yet valid. Valid from: ${validFrom.toLocal()} ❌',
      );
    }

    // If validUntil is set and current time is after it, not valid.
    if (validUntil != null && now.isAfter(validUntil)) {
      printRed('Ticket has expired. Valid until: ${validUntil.toLocal()} ❌');
      return (
        canScan: false,
        message: 'Ticket has expired. Valid until: ${validUntil.toLocal()} ❌',
      );
    }

    printGreen('Date Validity criteria is met! ✅');

    // --- 2. Check Daily Scan Limit ---
    if (ticketTypeData.maxScansPerDay != null) {
      final startOfToday = DateTime(now.year, now.month, now.day, 0, 0, 0);
      final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);

      // Count only successful scans within the current day
      final timesScannedToday = scanHistory.where((scan) {
        return scan.success &&
            scan.scannedAt.isAfter(
              startOfToday.subtract(const Duration(milliseconds: 1)),
            ) && // Inclusive start
            scan.scannedAt.isBefore(
              endOfToday.add(
                const Duration(milliseconds: 1),
              ),
            ); // Inclusive end
      }).length;

      printBlue('maxScansPerDay: ${ticketTypeData.maxScansPerDay}');
      printBlue('timesScannedToday: $timesScannedToday');
      if (timesScannedToday >= ticketTypeData.maxScansPerDay!) {
        printRed(
          'Ticket has reached its daily scan limit \n(${ticketTypeData.maxScansPerDay} scans today). ❌ ',
        );
        return (
          canScan: false,
          message:
              'Ticket has reached its daily scan limit \n(${ticketTypeData.maxScansPerDay} scans today). ❌ ',
        );
      }
      printGreen(
          'Daily scan limit criteria is met! Scanned $timesScannedToday times today. ✅');
    } else {
      printGreen('No daily scan limit set for this ticket type. ✅');
    }

    // If all checks pass, the ticket can be scanned.
    return (
      canScan: true,
      message: 'Ticket can be scanned. ✅',
    );
  }

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
    this.scanHistory = const <ScanEntry>[],

    // COMBO
    this.comboTicketId,
    this.comboId,
    this.comboCardNumber,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: toObjectId(json['_id']),
      event: parseEither<Event>(json['event'], Event.fromJson),
      ticketType:
          parseEither<TicketType>(json['ticketType'], TicketType.fromJson),
      issuedTo: TicketOwner.fromJson(
        json['issuedTo'] != null
            ? json['issuedTo'] as Map<String, dynamic>
            : TicketOwner.sampleData().toJson(),
      ),
      issuedAt: json['issuedAt'] != null
          ? DateTime.parse(json['issuedAt'].toString())
          : DateTime.now(),
      ticketNumber: json['ticketNumber'] as String,
      isScanned: json['isScanned'] as bool? ?? false,
      scannedAt: json['scannedAt'] != null
          ? DateTime.parse(json['scannedAt'] as String)
          : null,
      scannedBy: json['scannedBy'] != null
          ? parseEither<User>(json['scannedBy'], User.fromJson)
          : null,
      scanHistory: (json['scanHistory'] as List?)
              ?.map((e) => ScanEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],

      // COMBO
      comboTicketId: json['comboTicketId'] as String?,
      comboId: json['comboId'] as String?,
      comboCardNumber: json['comboCardNumber'] as String?,
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
      'scanHistory': scanHistory.map((scan) => scan.toJson()).toList(),

      // COMBO
      'comboTicketId': comboTicketId,
      'comboId': comboId,
      'comboCardNumber': comboCardNumber,
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
    List<ScanEntry>? scanHistory,

    // COMBO
    String? comboTicketId,
    String? comboId,
    String? comboCardNumber,
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
      scanHistory: scanHistory ?? this.scanHistory,

      // COMBO
      comboTicketId: comboTicketId ?? this.comboTicketId,
      comboId: comboId ?? this.comboId,
      comboCardNumber: comboCardNumber ?? this.comboCardNumber,
    );
  }
}

class TicketRequest {
  ObjectId event;
  ObjectId ticketType;
  TicketOwner issuedTo;
  DateTime issuedAt;
  String ticketNumber;

  // COMBO
  String? comboTicketId;
  String? comboId;
  String? comboCardNumber;

  TicketRequest({
    required this.event,
    required this.ticketType,
    required this.issuedTo,
    required this.issuedAt,
    required this.ticketNumber,

    // COMBO
    this.comboTicketId,
    this.comboId,
    this.comboCardNumber,
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

      // COMBO
      comboTicketId: json['comboTicketId'] as String?,
      comboId: json['comboId'] as String?,
      comboCardNumber: json['comboCardNumber'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event': event,
      'ticketType': ticketType,
      'issuedTo': issuedTo.toJson(),
      'issuedAt': issuedAt.toString(),
      'ticketNumber': ticketNumber,

      // COMBO
      'comboTicketId': comboTicketId,
      'comboId': comboId,
      'comboCardNumber': comboCardNumber,
    };
  }

  TicketRequest copyWith({
    ObjectId? event,
    ObjectId? ticketType,
    TicketOwner? issuedTo,
    DateTime? issuedAt,
    String? ticketNumber,

    // COMBO
    String? comboTicketId,
    String? comboId,
    String? comboCardNumber,
  }) {
    return TicketRequest(
      event: event ?? this.event,
      ticketType: ticketType ?? this.ticketType,
      issuedTo: issuedTo ?? this.issuedTo,
      issuedAt: issuedAt ?? this.issuedAt,
      ticketNumber: ticketNumber ?? this.ticketNumber,

      // COMBO
      comboTicketId: comboTicketId ?? this.comboTicketId,
      comboId: comboId ?? this.comboId,
      comboCardNumber: comboCardNumber ?? this.comboCardNumber,
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
