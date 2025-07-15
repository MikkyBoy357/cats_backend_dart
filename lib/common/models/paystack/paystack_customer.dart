class PaystackCustomer {
  int integration;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? metadata;
  String? domain;
  String? customerCode;
  String? riskAction;
  int? id;
  String? createdAt;
  String? updatedAt;

  PaystackCustomer({
    required this.integration,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.metadata,
    this.domain,
    this.customerCode,
    this.riskAction,
    this.id,
    this.createdAt,
    this.updatedAt,
  });

  factory PaystackCustomer.fromJson(Map<String, dynamic> json) {
    return PaystackCustomer(
      integration: json['integration'] as int,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      metadata: json['metadata'] as String?,
      domain: json['domain'] as String?,
      customerCode: json['customer_code'] as String?,
      riskAction: json['risk_action'] as String?,
      id: json['id'] as int?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'integration': integration,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'metadata': metadata,
      'domain': domain,
      'customer_code': customerCode,
      'risk_action': riskAction,
      'id': id,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
