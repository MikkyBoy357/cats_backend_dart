class TicketOwner {
  String name;
  String phone;
  String? email;

  TicketOwner({
    required this.name,
    required this.phone,
    this.email,
  });

  factory TicketOwner.fromJson(Map<String, dynamic> json) {
    return TicketOwner(
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      if (email != null) 'email': email,
    };
  }

  factory TicketOwner.sampleData() {
    return TicketOwner(
      name: 'John Doe',
      phone: '22901234567890',
      email: 'johndoe@gmail.com',
    );
  }
}
