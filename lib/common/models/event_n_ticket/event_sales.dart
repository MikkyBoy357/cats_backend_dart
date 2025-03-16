class EventSales {
  final int ticketsSold;
  final int ticketsScanned;

  EventSales({
    required this.ticketsSold,
    required this.ticketsScanned,
  });

  factory EventSales.fromJson(Map<String, dynamic> json) {
    return EventSales(
      ticketsSold: json['ticketsSold'] as int,
      ticketsScanned: json['ticketsScanned'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticketsSold': ticketsSold,
      'ticketsScanned': ticketsScanned,
    };
  }

  EventSales copyWith({
    int? ticketsSold,
    int? ticketsScanned,
  }) {
    return EventSales(
      ticketsSold: ticketsSold ?? this.ticketsSold,
      ticketsScanned: ticketsScanned ?? this.ticketsScanned,
    );
  }
}
