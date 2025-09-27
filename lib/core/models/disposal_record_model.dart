class DisposalRecordModel {
  final int? id;
  final String medicineName;
  final String batchNumber;
  final int quantity;
  final String disposalDate;
  final String disposalMethod;
  final String status;
  final String category;
  final String supplier;
  final String createdAt;
  final String updatedAt;

  DisposalRecordModel({
    this.id,
    required this.medicineName,
    required this.batchNumber,
    required this.quantity,
    required this.disposalDate,
    required this.disposalMethod,
    required this.status,
    required this.category,
    required this.supplier,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DisposalRecordModel.fromMap(Map<String, dynamic> map) {
    return DisposalRecordModel(
      id: map['id'],
      medicineName: map['medicine_name'] ?? '',
      batchNumber: map['batch_number'] ?? '',
      quantity: map['quantity'] ?? 0,
      disposalDate: map['disposal_date'] ?? '',
      disposalMethod: map['disposal_method'] ?? '',
      status: map['status'] ?? '',
      category: map['category'] ?? '',
      supplier: map['supplier'] ?? '',
      createdAt: map['created_at'] ?? '',
      updatedAt: map['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'medicine_name': medicineName,
      'batch_number': batchNumber,
      'quantity': quantity,
      'disposal_date': disposalDate,
      'disposal_method': disposalMethod,
      'status': status,
      'category': category,
      'supplier': supplier,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Convert to the format expected by existing UI components
  Map<String, dynamic> toUIMap() {
    return {
      'id': id,
      'medicineName': medicineName,
      'batchNumber': batchNumber,
      'quantity': quantity,
      'disposalDate': disposalDate,
      'disposalMethod': disposalMethod,
      'status': status,
      'category': category,
      'supplier': supplier,
    };
  }

  DisposalRecordModel copyWith({
    int? id,
    String? medicineName,
    String? batchNumber,
    int? quantity,
    String? disposalDate,
    String? disposalMethod,
    String? status,
    String? category,
    String? supplier,
    String? createdAt,
    String? updatedAt,
  }) {
    return DisposalRecordModel(
      id: id ?? this.id,
      medicineName: medicineName ?? this.medicineName,
      batchNumber: batchNumber ?? this.batchNumber,
      quantity: quantity ?? this.quantity,
      disposalDate: disposalDate ?? this.disposalDate,
      disposalMethod: disposalMethod ?? this.disposalMethod,
      status: status ?? this.status,
      category: category ?? this.category,
      supplier: supplier ?? this.supplier,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
