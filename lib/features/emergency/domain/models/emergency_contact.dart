class EmergencyContact {
  final String id;
  final String name;
  final String relation;
  final String phoneNumber;
  final String? address;
  final String? notes;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.relation,
    required this.phoneNumber,
    this.address,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'relation': relation,
      'phoneNumber': phoneNumber,
      'address': address,
      'notes': notes,
    };
  }

  factory EmergencyContact.fromJson(Map<String, dynamic> json, String id) {
    return EmergencyContact(
      id: id,
      name: json['name'] ?? '',
      relation: json['relation'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      address: json['address'],
      notes: json['notes'],
    );
  }
}
