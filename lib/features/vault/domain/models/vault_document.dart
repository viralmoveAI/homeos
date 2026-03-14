import 'package:cloud_firestore/cloud_firestore.dart';

enum VaultCategory {
  property,
  insurance,
  utilityService,
  applianceManual,
  maintenanceRecord,
  legalTax,
  vehicle,
  emergency,
  other;

  String get displayName {
    switch (this) {
      case VaultCategory.property:
        return 'Property';
      case VaultCategory.insurance:
        return 'Insurance';
      case VaultCategory.utilityService:
        return 'Utility & Service';
      case VaultCategory.applianceManual:
        return 'Appliance Manual';
      case VaultCategory.maintenanceRecord:
        return 'Maintenance Record';
      case VaultCategory.legalTax:
        return 'Legal & Tax';
      case VaultCategory.vehicle:
        return 'Vehicle';
      case VaultCategory.emergency:
        return 'Emergency';
      case VaultCategory.other:
        return 'Other';
    }
  }
}

enum FileType {
  pdf,
  image,
  document,
  other;

  String get displayName {
    switch (this) {
      case FileType.pdf:
        return 'PDF';
      case FileType.image:
        return 'Image';
      case FileType.document:
        return 'Document';
      case FileType.other:
        return 'Other';
    }
  }
}

class VaultDocument {
  final String id;
  final String title;
  final VaultCategory category;
  final FileType fileType;
  final String? fileReference;
  final DateTime? expiryDate;
  final String? description;
  final List<String> tags;
  final String? notes;
  final DateTime? createdAt;

  VaultDocument({
    required this.id,
    required this.title,
    required this.category,
    required this.fileType,
    this.fileReference,
    this.expiryDate,
    this.description,
    this.tags = const [],
    this.notes,
    this.createdAt,
  });

  VaultDocument copyWith({
    String? id,
    String? title,
    VaultCategory? category,
    FileType? fileType,
    String? fileReference,
    DateTime? expiryDate,
    String? description,
    List<String>? tags,
    String? notes,
    DateTime? createdAt,
  }) {
    return VaultDocument(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      fileType: fileType ?? this.fileType,
      fileReference: fileReference ?? this.fileReference,
      expiryDate: expiryDate ?? this.expiryDate,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category.name,
      'fileType': fileType.name,
      'fileReference': fileReference,
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'description': description,
      'tags': tags,
      'notes': notes,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory VaultDocument.fromJson(Map<String, dynamic> json, String id) {
    return VaultDocument(
      id: id,
      title: json['title'] ?? '',
      category: VaultCategory.values.firstWhere(
        (e) => e.name == (json['category'] ?? 'other'),
        orElse: () => VaultCategory.other,
      ),
      fileType: FileType.values.firstWhere(
        (e) => e.name == (json['fileType'] ?? 'other'),
        orElse: () => FileType.other,
      ),
      fileReference: json['fileReference'],
      expiryDate: json['expiryDate'] != null ? (json['expiryDate'] as Timestamp).toDate() : null,
      description: json['description'],
      tags: List<String>.from(json['tags'] ?? []),
      notes: json['notes'],
      createdAt: json['createdAt'] != null ? (json['createdAt'] as Timestamp).toDate() : null,
    );
  }
}
