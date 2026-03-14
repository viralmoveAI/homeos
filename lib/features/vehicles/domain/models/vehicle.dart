class Vehicle {
  final String id;
  final String name;
  final String? make;
  final String? model;
  final int? year;
  final String? licensePlate;
  final String? vin;
  final DateTime? lastServiceDate;
  final DateTime? nextServiceDate;
  final String? notes;
  final String? imageUrl;

  Vehicle({
    required this.id,
    required this.name,
    this.make,
    this.model,
    this.year,
    this.licensePlate,
    this.vin,
    this.lastServiceDate,
    this.nextServiceDate,
    this.notes,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'make': make,
      'model': model,
      'year': year,
      'licensePlate': licensePlate,
      'vin': vin,
      'lastServiceDate': lastServiceDate?.toIso8601String(),
      'nextServiceDate': nextServiceDate?.toIso8601String(),
      'notes': notes,
      'imageUrl': imageUrl,
    };
  }

  factory Vehicle.fromJson(Map<String, dynamic> json, String id) {
    return Vehicle(
      id: id,
      name: json['name'] ?? '',
      make: json['make'],
      model: json['model'],
      year: json['year'],
      licensePlate: json['licensePlate'],
      vin: json['vin'],
      lastServiceDate: json['lastServiceDate'] != null ? DateTime.parse(json['lastServiceDate']) : null,
      nextServiceDate: json['nextServiceDate'] != null ? DateTime.parse(json['nextServiceDate']) : null,
      notes: json['notes'],
      imageUrl: json['imageUrl'],
    );
  }
}
