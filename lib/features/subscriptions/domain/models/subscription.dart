class Subscription {
  final String id;
  final String name;
  final double amount;
  final String billingCycle;
  final String category;
  final DateTime nextRenewalDate;
  final bool isActive;

  Subscription({
    required this.id,
    required this.name,
    required this.amount,
    required this.billingCycle,
    required this.category,
    required this.nextRenewalDate,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'billingCycle': billingCycle,
      'category': category,
      'nextRenewalDate': nextRenewalDate.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory Subscription.fromJson(Map<String, dynamic> json, String id) {
    return Subscription(
      id: id,
      name: json['name'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      billingCycle: json['billingCycle'] ?? 'Monthly',
      category: json['category'] ?? 'Other',
      nextRenewalDate: DateTime.parse(json['nextRenewalDate']),
      isActive: json['isActive'] ?? true,
    );
  }
}
