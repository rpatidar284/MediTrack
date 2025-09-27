// lib/presentation/sales_reports_screen/sales_reports_controller.dart

import 'package:flutter/material.dart';
import 'package:meditrack_pro/core/services/medicine_service.dart';

class SalesReportsController extends ChangeNotifier {
  final MedicineService _medicineService = MedicineService();

  String _selectedDateRange = 'Month';
  String _selectedReportType = 'sales_summary';
  bool _isLoading = false;

  Map<String, dynamic> _reportData = {};

  String get selectedDateRange => _selectedDateRange;
  String get selectedReportType => _selectedReportType;
  bool get isLoading => _isLoading;
  Map<String, dynamic> get reportData => _reportData;

  SalesReportsController() {
    _medicineService.addListener(loadData);
    loadData();
  }

  @override
  void dispose() {
    _medicineService.removeListener(loadData);
    super.dispose();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      DateTime startDate;

      switch (_selectedDateRange) {
        case 'Today':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'Week':
          startDate = now.subtract(Duration(days: now.weekday - 1));
          break;
        case 'Month':
          startDate = DateTime(now.year, now.month, 1);
          break;
        case 'Quarter':
          final currentMonth = now.month;
          int startMonth = 1;
          if (currentMonth >= 4 && currentMonth <= 6) startMonth = 4;
          if (currentMonth >= 7 && currentMonth <= 9) startMonth = 7;
          if (currentMonth >= 10 && currentMonth <= 12) startMonth = 10;
          startDate = DateTime(now.year, startMonth, 1);
          break;
        default: // Custom or other cases
          startDate = DateTime(now.year, now.month, 1); // Default to month
          break;
      }

      final endDate = now;

      final salesSummary =
          await _medicineService.getSalesSummary(startDate, endDate);
      final topSelling =
          await _medicineService.getTopSellingMedicines(startDate, endDate, 5);
      final profitAnalysis =
          await _medicineService.getProfitAnalysis(startDate, endDate);
      final inventoryTurnover = await _medicineService.getInventoryTurnover();
      final productPerformance =
          await _medicineService.getProductPerformance(startDate, endDate);

      _reportData = {
        'sales_summary': salesSummary,
        'top_selling': topSelling,
        'profit_analysis': profitAnalysis,
        'inventory_turnover': inventoryTurnover,
        'product_performance': productPerformance,
      };
    } catch (e) {
      // Handle error, e.g., show a toast
      print('Error loading sales reports: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void onDateRangeChanged(String range) {
    _selectedDateRange = range;
    loadData();
  }

  void onCustomRangeSelected(DateTime start, DateTime end) {
    _selectedDateRange =
        'Custom (${start.day}/${start.month} - ${end.day}/${end.month})';
    loadData();
  }

  void onReportTypeChanged(String type) {
    _selectedReportType = type;
    notifyListeners();
  }
}
