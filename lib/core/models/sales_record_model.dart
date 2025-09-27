// lib/core/models/sales_record_model.dart

class SalesRecordModel {
  final int? id;
  final int medicineId;
  final String medicineName;
  final int quantitySold;
  final double unitPrice;
  final double totalAmount;
  final String? customerName;
  final String? customerPhone;
  final String paymentMethod;
  final String saleDate;
  final String createdAt;

  SalesRecordModel({
    this.id,
    required this.medicineId,
    required this.medicineName,
    required this.quantitySold,
    required this.unitPrice,
    required this.totalAmount,
    this.customerName,
    this.customerPhone,
    required this.paymentMethod,
    required this.saleDate,
    required this.createdAt,
  });

  factory SalesRecordModel.fromMap(Map<String, dynamic> map) {
    return SalesRecordModel(
      id: map['id'],
      medicineId: map['medicine_id'] as int,
      medicineName: map['medicine_name'] ?? '',
      quantitySold: map['quantity_sold'] ?? 0,
      unitPrice: (map['unit_price'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (map['total_amount'] as num?)?.toDouble() ?? 0.0,
      customerName: map['customer_name'],
      customerPhone: map['customer_phone'],
      paymentMethod: map['payment_method'] ?? '',
      saleDate: map['sale_date'] ?? '',
      createdAt: map['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'medicine_id': medicineId,
      'medicine_name': medicineName,
      'quantity_sold': quantitySold,
      'unit_price': unitPrice,
      'total_amount': totalAmount,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'payment_method': paymentMethod,
      'sale_date': saleDate,
      'created_at': createdAt,
    };
  }
}
