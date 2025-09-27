import 'package:flutter/material.dart';
import '../presentation/add_medicine_screen/add_medicine_screen.dart';
import '../presentation/dashboard_screen/dashboard_screen.dart';
import '../presentation/sales_recording_screen/sales_recording_screen.dart';
import '../presentation/medicine_inventory_screen/medicine_inventory_screen.dart';
import '../presentation/expiry_management_screen/expiry_management_screen.dart';
import '../presentation/sales_reports_screen/sales_reports_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/dashboard-screen';
  static const String addMedicine = '/add-medicine-screen';
  static const String dashboard = '/dashboard-screen';
  static const String salesRecording = '/sales-recording-screen';
  static const String medicineInventory = '/medicine-inventory-screen';
  static const String expiryManagement = '/expiry-management-screen';
  static const String salesReports = '/sales-reports-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const DashboardScreen(),
    addMedicine: (context) => const AddMedicineScreen(),
    dashboard: (context) => const DashboardScreen(),
    salesRecording: (context) => const SalesRecordingScreen(),
    medicineInventory: (context) => const MedicineInventoryScreen(),
    expiryManagement: (context) => const ExpiryManagementScreen(),
    salesReports: (context) => const SalesReportsScreen(),
    // TODO: Add your other routes here
  };
}
