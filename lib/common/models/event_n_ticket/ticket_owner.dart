class TicketOwner {
  String name;
  String email;
  String? phone;

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

  factory TicketOwner.sampleData() {
    return TicketOwner(
      name: 'John Doe',
      email: 'johndoe@gmail.com',
      phone: '22901234567890',
    );
  }
}
