// lib/presentation/dashboard_screen/dashboard_controller.dart

import 'package:flutter/material.dart';
import 'package:meditrack_pro/core/services/medicine_service.dart';

class DashboardController extends ChangeNotifier {
  final MedicineService _medicineService = MedicineService();
  bool _isLoading = true;
  String _selectedChartPeriod = 'Daily';

  // State for metrics
  String _totalStockValue = "\$0";
  int _totalMedicines = 0;
  int _expiringSoonCount = 0;
  double _todaySales = 0.0;
  int _todayTransactions = 0;
  int _lowStockCount = 0;

  // State for charts and activities
  List<Map<String, dynamic>> _salesData = [];
  List<Map<String, dynamic>> _recentActivities = [];

  bool get isLoading => _isLoading;
  String get selectedChartPeriod => _selectedChartPeriod;

  String get totalStockValue => _totalStockValue;
  int get totalMedicines => _totalMedicines;
  int get expiringSoonCount => _expiringSoonCount;
  double get todaySales => _todaySales;
  int get todayTransactions => _todayTransactions;
  int get lowStockCount => _lowStockCount;

  List<Map<String, dynamic>> get salesData => _salesData;
  List<Map<String, dynamic>> get recentActivities => _recentActivities;

  DashboardController() {
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
      final today = DateTime(now.year, now.month, now.day);

      // Fetch metrics
      final stockValue = await _medicineService.getTotalStockValue();
      final totalMeds = await _medicineService.getMedicineCount();
      final expiring = await _medicineService.getExpiringSoonCount(90);
      final lowStock = await _medicineService.getLowStockCount(10);

      // Fetch today's sales
      final todaySalesData = await _medicineService.getSalesSummary(today, now);

      // Fetch recent activity
      final activities = await _medicineService.getRecentActivity(10);

      _totalStockValue = "\$${stockValue.toStringAsFixed(0)}";
      _totalMedicines = totalMeds;
      _expiringSoonCount = expiring;
      _lowStockCount = lowStock;
      _todaySales = (todaySalesData['totalSales'] as num).toDouble();
      _todayTransactions = (todaySalesData['transactionCount'] as num).toInt();
      _recentActivities = activities;

      // Fetch sales chart data for the initial period
      await _loadSalesChartData();
    } catch (e) {
      // Handle error
      print('Error loading dashboard data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadSalesChartData() async {
    DateTime now = DateTime.now();
    DateTime startDate = now.subtract(const Duration(days: 6));

    // This part will need to be expanded to handle other periods
    final salesChartData =
        await _medicineService.getSalesDataForChart(startDate, now);
    _salesData = salesChartData;
    notifyListeners();
  }

  void onChartPeriodChanged(String period) {
    _selectedChartPeriod = period;
    // TODO: Implement logic to fetch data for other periods
    _loadSalesChartData(); // For now, we only have daily data
    notifyListeners();
  }
}
