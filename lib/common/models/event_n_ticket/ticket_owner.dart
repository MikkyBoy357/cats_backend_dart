class TicketOwner {
  final String name;
  final String email;
  final String? phone;

  TicketOwner({
    required this.name,
    required this.email,
    this.phone,
  });

  factory TicketOwner.fromJson(Map<String, dynamic> json) {
    return TicketOwner(
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      if (phone != null) 'phone': phone,
    };
  }
}
