import 'package:mongo_dart/mongo_dart.dart';

class EventSales {
  final int ticketsSold;
  final int ticketsScanned;
  final int totalTicketSupply;
  final Map<String, TicketTypeSales> ticketTypeSales;

  EventSales({
    required this.ticketsSold,
    required this.ticketsScanned,
    required this.totalTicketSupply,
    this.ticketTypeSales = const {},
  });

  Map<String, dynamic> toJson() => {
        'ticketsSold': ticketsSold,
        'ticketsScanned': ticketsScanned,
        'totalTicketSupply': totalTicketSupply,
        'ticketTypeSales':
            ticketTypeSales.map((key, value) => MapEntry(key, value.toJson())),
      };

  factory EventSales.fromJson(Map<String, dynamic> json) {
    return EventSales(
      ticketsSold: json['ticketsSold'] as int,
      ticketsScanned: json['ticketsScanned'] as int,
      totalTicketSupply: json['totalTicketSupply'] as int,
      ticketTypeSales: (json['ticketTypeSales'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              key,
              TicketTypeSales.fromJson(value as Map<String, dynamic>),
            ),
          ) ??
          {},
    );
  }
}

class TicketTypeSales {
  final ObjectId ticketTypeId;
  final String name;
  final int sold;
  final int scanned;
  final int totalSupply;

  TicketTypeSales({
    required this.ticketTypeId,
    required this.name,
    required this.sold,
    required this.scanned,
    required this.totalSupply,
  });

  Map<String, dynamic> toJson() => {
        'ticketTypeId': ticketTypeId.oid,
        'name': name,
        'sold': sold,
        'scanned': scanned,
        'totalSupply': totalSupply,
      };

  factory TicketTypeSales.fromJson(Map<String, dynamic> json) {
    return TicketTypeSales(
      ticketTypeId: ObjectId.parse(json['ticketTypeId'] as String),
      name: json['name'] as String,
      sold: json['sold'] as int,
      scanned: json['scanned'] as int,
      totalSupply: json['totalSupply'] as int,
    );
  }
}
