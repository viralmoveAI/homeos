class Utility {
  final String id;
  final String name;
  final String type;
  final String provider;
  final String accountNumber;
  final double monthlyCost;
  final String? billingDate;
  final String? notes;

  Utility({
    required this.id,
    required this.name,
    required this.type,
    required this.provider,
    required this.accountNumber,
    required this.monthlyCost,
    this.billingDate,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'provider': provider,
      'accountNumber': accountNumber,
      'monthlyCost': monthlyCost,
      'billingDate': billingDate,
      'notes': notes,
    };
  }

  factory Utility.fromJson(Map<String, dynamic> json, String id) {
    return Utility(
      id: id,
      name: json['name'] ?? '',
      type: json['type'] ?? 'Other',
      provider: json['provider'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      monthlyCost: (json['monthlyCost'] ?? json['averageMonthlyCost'] ?? 0.0).toDouble(),
      billingDate: json['billingDate'],
      notes: json['notes'],
    );
  }
}
