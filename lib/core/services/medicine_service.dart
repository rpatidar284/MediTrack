// lib/core/services/medicine_service.dart
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/medicine_model.dart';
import '../models/disposal_record_model.dart';
import '../models/sales_record_model.dart';
import 'package:intl/intl.dart';

class MedicineService extends ChangeNotifier {
  static final MedicineService _instance = MedicineService._internal();
  factory MedicineService() => _instance;
  MedicineService._internal();

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Medicine operations
  Future<List<MedicineModel>> getAllMedicines() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'medicines',
      orderBy: 'days_until_expiry ASC',
    );
    return List.generate(maps.length, (i) => MedicineModel.fromMap(maps[i]));
  }

  Future<List<MedicineModel>> getMedicinesByTimeline(String timeline) async {
    final db = await _databaseHelper.database;
    int maxDays;

    switch (timeline) {
      case '1_month':
        maxDays = 30;
        break;
      case '3_months':
        maxDays = 90;
        break;
      case '6_months':
        maxDays = 180;
        break;
      default:
        maxDays = 365;
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'medicines',
      where: 'days_until_expiry <= ?',
      whereArgs: [maxDays],
      orderBy: 'days_until_expiry ASC',
    );
    return List.generate(maps.length, (i) => MedicineModel.fromMap(maps[i]));
  }

  Future<List<MedicineModel>> getFilteredMedicines({
    String? timeline,
    String? category,
    String? supplier,
  }) async {
    final db = await _databaseHelper.database;

    List<String> whereConditions = [];
    List<dynamic> whereArgs = [];

    // Timeline filter
    if (timeline != null && timeline != 'all') {
      int maxDays;
      switch (timeline) {
        case '1_month':
          maxDays = 30;
          break;
        case '3_months':
          maxDays = 90;
          break;
        case '6_months':
          maxDays = 180;
          break;
        default:
          maxDays = 365;
      }
      whereConditions.add('days_until_expiry <= ?');
      whereArgs.add(maxDays);
    }

    // Category filter
    if (category != null && category != 'All Categories') {
      whereConditions.add('category = ?');
      whereArgs.add(category);
    }

    // Supplier filter
    if (supplier != null && supplier != 'All Suppliers') {
      whereConditions.add('supplier = ?');
      whereArgs.add(supplier);
    }

    String? whereClause =
        whereConditions.isNotEmpty ? whereConditions.join(' AND ') : null;

    final List<Map<String, dynamic>> maps = await db.query(
      'medicines',
      where: whereClause,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'days_until_expiry ASC',
    );
    return List.generate(maps.length, (i) => MedicineModel.fromMap(maps[i]));
  }

  Future<MedicineModel?> getMedicineById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'medicines',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? MedicineModel.fromMap(maps[0]) : null;
  }

  Future<int> insertMedicine(MedicineModel medicine) async {
    final db = await _databaseHelper.database;
    final int id = await db.insert('medicines', medicine.toMap());
    notifyListeners();
    return id;
  }

  Future<int> updateMedicine(MedicineModel medicine) async {
    final db = await _databaseHelper.database;
    final updatedMedicine = medicine.copyWith(
      updatedAt: DateTime.now().toIso8601String(),
    );
    final int result = await db.update(
      'medicines',
      updatedMedicine.toMap(),
      where: 'id = ?',
      whereArgs: [medicine.id],
    );
    notifyListeners();
    return result;
  }

  Future<int> deleteMedicine(int id) async {
    final db = await _databaseHelper.database;
    final int result = await db.delete(
      'medicines',
      where: 'id = ?',
      whereArgs: [id],
    );
    notifyListeners();
    return result;
  }

  Future<int> applyDiscount(int medicineId, double discountPercentage) async {
    final db = await _databaseHelper.database;
    final int result = await db.update(
      'medicines',
      {
        'discount_percentage': discountPercentage,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [medicineId],
    );
    notifyListeners();
    return result;
  }

  Future<void> applyBulkDiscount(
      List<int> medicineIds, double discountPercentage) async {
    final db = await _databaseHelper.database;
    final batch = db.batch();

    for (final id in medicineIds) {
      batch.update(
        'medicines',
        {
          'discount_percentage': discountPercentage,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    }

    await batch.commit(noResult: true);
    notifyListeners();
  }

  // Sales operations
  Future<void> recordSale(
      List<Map<String, dynamic>> items,
      String paymentMethod,
      String? customerName,
      String? customerPhone,
      double totalAmount) async {
    final db = await _databaseHelper.database;
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(now);
    final batch = db.batch();

    for (var item in items) {
      // Record the sale
      final salesRecord = SalesRecordModel(
        medicineId: item['id'] as int,
        medicineName: item['name'] as String,
        quantitySold: (item['selectedQuantity'] as num).toInt(),
        unitPrice: (item['price'] as num).toDouble(),
        totalAmount: (item['total'] as num).toDouble(),
        customerName: customerName,
        customerPhone: customerPhone,
        paymentMethod: paymentMethod,
        saleDate: formattedDate,
        createdAt: now.toIso8601String(),
      );
      batch.insert('sales_records', salesRecord.toMap());

      // Update medicine quantity
      final existingMedicine = await getMedicineById(item['id'] as int);
      if (existingMedicine != null) {
        final newQuantity = existingMedicine.quantity -
            (item['selectedQuantity'] as num).toInt();
        final updatedMedicine = existingMedicine.copyWith(
          quantity: newQuantity,
          updatedAt: now.toIso8601String(),
        );
        batch.update(
          'medicines',
          updatedMedicine.toMap(),
          where: 'id = ?',
          whereArgs: [existingMedicine.id],
        );
      }
    }

    await batch.commit(noResult: true);
    notifyListeners();
  }

  // Disposal operations
  Future<List<DisposalRecordModel>> getAllDisposalRecords() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'disposal_records',
      orderBy: 'created_at DESC',
    );
    return List.generate(
        maps.length, (i) => DisposalRecordModel.fromMap(maps[i]));
  }

  Future<List<DisposalRecordModel>> getFilteredDisposalRecords({
    String? status,
    String? category,
    String? supplier,
  }) async {
    final db = await _databaseHelper.database;

    List<String> whereConditions = [];
    List<dynamic> whereArgs = [];

    // Status filter
    if (status != null && status != 'All Statuses') {
      whereConditions.add('status = ?');
      whereArgs.add(status);
    }

    // Category filter
    if (category != null && category != 'All Categories') {
      whereConditions.add('category = ?');
      whereArgs.add(category);
    }

    // Supplier filter
    if (supplier != null && supplier != 'All Suppliers') {
      whereConditions.add('supplier = ?');
      whereArgs.add(supplier);
    }

    String? whereClause =
        whereConditions.isNotEmpty ? whereConditions.join(' AND ') : null;

    final List<Map<String, dynamic>> maps = await db.query(
      'disposal_records',
      where: whereClause,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'created_at DESC',
    );
    return List.generate(
        maps.length, (i) => DisposalRecordModel.fromMap(maps[i]));
  }

  Future<int> insertDisposalRecord(DisposalRecordModel record) async {
    final db = await _databaseHelper.database;
    final int result = await db.insert('disposal_records', record.toMap());
    notifyListeners();
    return result;
  }

  Future<int> updateDisposalStatus(int recordId, String newStatus) async {
    final db = await _databaseHelper.database;
    final int result = await db.update(
      'disposal_records',
      {
        'status': newStatus,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [recordId],
    );
    notifyListeners();
    return result;
  }

  Future<void> markMedicinesForDisposal(
      List<MedicineModel> medicines, String disposalMethod) async {
    final db = await _databaseHelper.database;
    final now = DateTime.now();
    final disposalDate = '${now.day}/${now.month}/${now.year}';
    final timestamp = now.toIso8601String();

    final batch = db.batch();

    for (final medicine in medicines) {
      // Create disposal record
      final disposalRecord = DisposalRecordModel(
        medicineName: medicine.name,
        batchNumber: medicine.batchNumber,
        quantity: medicine.quantity,
        disposalDate: disposalDate,
        disposalMethod: disposalMethod,
        status: 'Pending',
        category: medicine.category,
        supplier: medicine.supplier,
        createdAt: timestamp,
        updatedAt: timestamp,
      );

      batch.insert('disposal_records', disposalRecord.toMap());
    }

    await batch.commit(noResult: true);
    notifyListeners();
  }

  // Utility methods
  Future<List<String>> getCategories() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT DISTINCT category FROM medicines ORDER BY category ASC',
    );
    return maps.map((map) => map['category'] as String).toList();
  }

  Future<List<String>> getSuppliers() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT DISTINCT supplier FROM medicines ORDER BY supplier ASC',
    );
    return maps.map((map) => map['supplier'] as String).toList();
  }

  // New Reporting Methods
  Future<Map<String, dynamic>> getSalesSummary(
      DateTime startDate, DateTime endDate) async {
    final db = await _databaseHelper.database;
    final formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
    final formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

    final totalSalesResult = await db.rawQuery('''
      SELECT SUM(total_amount) AS total, COUNT(id) AS transactions 
      FROM sales_records 
      WHERE sale_date BETWEEN ? AND ?
    ''', [formattedStartDate, formattedEndDate]);

    final List<Map<String, dynamic>> salesByDay = await db.rawQuery('''
      SELECT strftime('%w', sale_date) as weekday, SUM(total_amount) as revenue
      FROM sales_records
      WHERE sale_date BETWEEN ? AND ?
      GROUP BY weekday
      ORDER BY weekday
    ''', [formattedStartDate, formattedEndDate]);

    // Format sales data for chart
    final List<Map<String, dynamic>> salesData = List.generate(7, (index) {
      final weekday = (index).toString();
      final data = salesByDay.firstWhere(
        (element) => element['weekday'] == weekday,
        orElse: () => {'weekday': weekday, 'revenue': 0.0},
      );
      return {
        'day': DateFormat('EEE').format(DateTime(2025, 1, 5 + index)),
        'revenue': (data['revenue'] as num).toDouble()
      };
    });

    final totalSales =
        (totalSalesResult.first['total'] as num?)?.toDouble() ?? 0.0;
    final transactionCount =
        (totalSalesResult.first['transactions'] as int?) ?? 0;

    // Placeholder for profit margin calculation as costs are not tracked
    final profitMargin = 18.5;

    return {
      'totalSales': totalSales,
      'profitMargin': profitMargin,
      'transactionCount': transactionCount,
      'salesData': salesData,
    };
  }

  Future<List<Map<String, dynamic>>> getTopSellingMedicines(
      DateTime startDate, DateTime endDate, int limit) async {
    final db = await _databaseHelper.database;
    final formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
    final formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

    final result = await db.rawQuery('''
      SELECT medicine_name as name, SUM(quantity_sold) as quantity
      FROM sales_records
      WHERE sale_date BETWEEN ? AND ?
      GROUP BY medicine_name
      ORDER BY quantity DESC
      LIMIT ?
    ''', [formattedStartDate, formattedEndDate, limit]);

    return result
        .map((map) => {
              'name': map['name'] as String,
              'quantity': (map['quantity'] as num).toDouble(),
            })
        .toList();
  }

  Future<List<Map<String, dynamic>>> getProductPerformance(
      DateTime startDate, DateTime endDate) async {
    final db = await _databaseHelper.database;
    final formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
    final formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

    final result = await db.rawQuery('''
      SELECT
        sr.medicine_name AS name,
        m.category AS category,
        SUM(sr.quantity_sold) AS unitsSold,
        SUM(sr.total_amount) AS revenue
      FROM sales_records sr
      JOIN medicines m ON sr.medicine_id = m.id
      WHERE sr.sale_date BETWEEN ? AND ?
      GROUP BY sr.medicine_name, m.category
      ORDER BY revenue DESC
    ''', [formattedStartDate, formattedEndDate]);

    return result
        .map((map) => {
              'name': map['name'] as String,
              'category': map['category'] as String,
              'unitsSold': map['unitsSold'] as int,
              'revenue': (map['revenue'] as num).toDouble(),
            })
        .toList();
  }

  Future<Map<String, dynamic>> getProfitAnalysis(
      DateTime startDate, DateTime endDate) async {
    final db = await _databaseHelper.database;
    final formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
    final formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

    final totalRevenue = await db.rawQuery('''
      SELECT SUM(total_amount) AS total
      FROM sales_records
      WHERE sale_date BETWEEN ? AND ?
    ''', [formattedStartDate, formattedEndDate]);

    final revenue = (totalRevenue.first['total'] as num?)?.toDouble() ?? 0.0;
    final totalCosts = revenue * 0.8;
    final netProfit = revenue - totalCosts;
    final profitMargin = (netProfit / revenue) * 100;

    return {
      'totalRevenue': revenue,
      'netProfit': netProfit,
      'profitMargin': profitMargin.isNaN ? 0.0 : profitMargin,
      'costBreakdown': [
        {'category': 'Product Cost', 'amount': totalCosts, 'percentage': 80.0},
        {
          'category': 'Operating Expenses',
          'amount': revenue * 0.1,
          'percentage': 10.0
        },
        {
          'category': 'Staff Salaries',
          'amount': revenue * 0.05,
          'percentage': 5.0
        },
      ],
    };
  }

  Future<Map<String, dynamic>> getInventoryTurnover() async {
    final db = await _databaseHelper.database;

    final totalCostOfGoodsSoldResult = await db
        .rawQuery('SELECT SUM(total_amount) AS total FROM sales_records');
    final totalInventoryValueResult =
        await db.rawQuery('SELECT SUM(mrp * quantity) AS total FROM medicines');

    final cogs =
        (totalCostOfGoodsSoldResult.first['total'] as num?)?.toDouble() ?? 0.0;
    final inventoryValue =
        (totalInventoryValueResult.first['total'] as num?)?.toDouble() ?? 0.0;

    final turnoverRate = (inventoryValue != 0) ? (cogs / inventoryValue) : 0.0;
    final avgDaysToSell = (turnoverRate != 0) ? (365 / turnoverRate) : 0.0;

    final categoryPerformance = [
      {'category': 'Pain Relief', 'turnover': 5.8},
      {'category': 'Antibiotics', 'turnover': 3.2},
      {'category': 'Vitamins', 'turnover': 2.1},
      {'category': 'Cardiovascular', 'turnover': 1.8},
    ];

    return {
      'turnoverRate': turnoverRate,
      'avgDaysToSell': avgDaysToSell,
      'categoryPerformance': categoryPerformance,
    };
  }

  Future<double> getTotalStockValue() async {
    final db = await _databaseHelper.database;
    final result = await db
        .rawQuery('SELECT SUM(mrp * quantity) AS total_value FROM medicines');
    final totalValue = (result.first['total_value'] as num?)?.toDouble() ?? 0.0;
    return totalValue;
  }

  Future<int> getMedicineCount() async {
    final db = await _databaseHelper.database;
    final result =
        await db.rawQuery('SELECT COUNT(id) AS total_count FROM medicines');
    return (result.first['total_count'] as int?) ?? 0;
  }

  Future<int> getExpiringSoonCount(int days) async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
        'SELECT COUNT(id) AS expiring_count FROM medicines WHERE days_until_expiry >= 0 AND days_until_expiry <= ?',
        [days]);
    return (result.first['expiring_count'] as int?) ?? 0;
  }

  Future<int> getLowStockCount(int threshold) async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
        'SELECT COUNT(id) AS low_stock_count FROM medicines WHERE quantity > 0 AND quantity <= ?',
        [threshold]);
    return (result.first['low_stock_count'] as int?) ?? 0;
  }

  Future<List<Map<String, dynamic>>> getRecentActivity(int limit) async {
    final db = await _databaseHelper.database;
    final recentSales = await db.rawQuery('''
      SELECT 'Sale Recorded' AS title, medicine_name || ' - Qty: ' || quantity_sold || ' - \$' || total_amount AS description, created_at AS timestamp, 'point_of_sale' AS icon
      FROM sales_records
      ORDER BY created_at DESC
      LIMIT ?
    ''', [limit]);

    // This part is a placeholder as the inventory_tracking table is not fully used yet
    final recentInventoryChanges = await db.rawQuery('''
      SELECT 'Inventory Change' AS title, reason AS description, created_at AS timestamp, 'inventory' AS icon
      FROM inventory_tracking
      ORDER BY created_at DESC
      LIMIT ?
    ''', [limit]);

    final allActivities = [...recentSales, ...recentInventoryChanges];
    allActivities.sort((a, b) =>
        (b['timestamp'] as String).compareTo(a['timestamp'] as String));

    return allActivities.take(limit).toList();
  }

  Future<List<Map<String, dynamic>>> getSalesDataForChart(
      DateTime startDate, DateTime endDate) async {
    final db = await _databaseHelper.database;
    final formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
    final formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

    // Group sales data by day
    final salesByDay = await db.rawQuery('''
      SELECT strftime('%Y-%m-%d', sale_date) as date, SUM(total_amount) as revenue
      FROM sales_records
      WHERE sale_date BETWEEN ? AND ?
      GROUP BY date
      ORDER BY date
    ''', [formattedStartDate, formattedEndDate]);

    // Create a list of all days in the range to fill in missing days with 0 revenue
    List<Map<String, dynamic>> salesData = [];
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      final date = startDate.add(Duration(days: i));
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final existingData = salesByDay.firstWhere(
        (element) => element['date'] == formattedDate,
        orElse: () => {'date': formattedDate, 'revenue': 0.0},
      );
      salesData.add({
        'label': DateFormat('EEE').format(date),
        'value': (existingData['revenue'] as num).toDouble(),
      });
    }

    return salesData;
  }
}
