enum ApplianceCategory {
  kitchen('Kitchen'),
  laundry('Laundry'),
  cleaning('Cleaning'),
  entertainment('Entertainment'),
  hvac('HVAC'),
  other('Other');

  final String displayName;
  const ApplianceCategory(this.displayName);
}

class Appliance {
  final String id;
  final String name;
  final ApplianceCategory category;
  final String brand;
  final String model;
  final String? serialNumber;
  final String location;
  final DateTime purchaseDate;
  final DateTime? warrantyExpiry;
  final int serviceIntervalMonths;
  final DateTime? lastServiceDate;
  final String? notes;

  Appliance({
    required this.id,
    required this.name,
    required this.category,
    required this.brand,
    required this.model,
    this.serialNumber,
    required this.location,
    required this.purchaseDate,
    this.warrantyExpiry,
    this.serviceIntervalMonths = 12,
    this.lastServiceDate,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category.name,
      'brand': brand,
      'model': model,
      'serialNumber': serialNumber,
      'location': location,
      'purchaseDate': purchaseDate.toIso8601String(),
      'warrantyExpiry': warrantyExpiry?.toIso8601String(),
      'serviceIntervalMonths': serviceIntervalMonths,
      'lastServiceDate': lastServiceDate?.toIso8601String(),
      'notes': notes,
    };
  }

  factory Appliance.fromJson(Map<String, dynamic> json, String id) {
    return Appliance(
      id: id,
      name: json['name'] ?? '',
      category: ApplianceCategory.values.firstWhere(
        (e) => e.name == (json['category'] ?? 'other'),
        orElse: () => ApplianceCategory.other,
      ),
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      serialNumber: json['serialNumber'],
      location: json['location'] ?? '',
      purchaseDate: DateTime.parse(json['purchaseDate']),
      warrantyExpiry: json['warrantyExpiry'] != null ? DateTime.parse(json['warrantyExpiry']) : null,
      serviceIntervalMonths: json['serviceIntervalMonths'] ?? 12,
      lastServiceDate: json['lastServiceDate'] != null ? DateTime.parse(json['lastServiceDate']) : null,
      notes: json['notes'],
    );
  }
}
