class MedicineModel {
  final int? id;
  final String name;
  final String batchNumber;
  final int quantity;
  final double mrp;
  final String category;
  final String supplier;
  final String expiryDate;
  final int daysUntilExpiry;
  final int? suggestedDiscount;
  final double? discountPercentage;
  final String createdAt;
  final String updatedAt;

  MedicineModel({
    this.id,
    required this.name,
    required this.batchNumber,
    required this.quantity,
    required this.mrp,
    required this.category,
    required this.supplier,
    required this.expiryDate,
    required this.daysUntilExpiry,
    this.suggestedDiscount,
    this.discountPercentage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MedicineModel.fromMap(Map<String, dynamic> map) {
    return MedicineModel(
      id: map['id'],
      name: map['name'] ?? '',
      batchNumber: map['batch_number'] ?? '',
      quantity: map['quantity'] ?? 0,
      mrp: (map['mrp'] ?? 0.0).toDouble(),
      category: map['category'] ?? '',
      supplier: map['supplier'] ?? '',
      expiryDate: map['expiry_date'] ?? '',
      daysUntilExpiry: map['days_until_expiry'] ?? 0,
      suggestedDiscount: map['suggested_discount'],
      discountPercentage: map['discount_percentage']?.toDouble(),
      createdAt: map['created_at'] ?? '',
      updatedAt: map['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'batch_number': batchNumber,
      'quantity': quantity,
      'mrp': mrp,
      'category': category,
      'supplier': supplier,
      'expiry_date': expiryDate,
      'days_until_expiry': daysUntilExpiry,
      'suggested_discount': suggestedDiscount,
      'discount_percentage': discountPercentage,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Convert to the format expected by existing UI components
  Map<String, dynamic> toUIMap() {
    return {
      'id': id,
      'name': name,
      'batchNumber': batchNumber,
      'quantity': quantity,
      'mrp': mrp,
      'category': category,
      'supplier': supplier,
      'expiryDate': expiryDate,
      'daysUntilExpiry': daysUntilExpiry,
      'suggestedDiscount': suggestedDiscount,
      'discountPercentage': discountPercentage,
    };
  }

  MedicineModel copyWith({
    int? id,
    String? name,
    String? batchNumber,
    int? quantity,
    double? mrp,
    String? category,
    String? supplier,
    String? expiryDate,
    int? daysUntilExpiry,
    int? suggestedDiscount,
    double? discountPercentage,
    String? createdAt,
    String? updatedAt,
  }) {
    return MedicineModel(
      id: id ?? this.id,
      name: name ?? this.name,
      batchNumber: batchNumber ?? this.batchNumber,
      quantity: quantity ?? this.quantity,
      mrp: mrp ?? this.mrp,
      category: category ?? this.category,
      supplier: supplier ?? this.supplier,
      expiryDate: expiryDate ?? this.expiryDate,
      daysUntilExpiry: daysUntilExpiry ?? this.daysUntilExpiry,
      suggestedDiscount: suggestedDiscount ?? this.suggestedDiscount,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
