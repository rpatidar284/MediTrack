import 'package:flutter/material.dart';
import 'package:meditrack_pro/presentation/add_medicine_screen/add_medicine_screen.dart';
import 'package:meditrack_pro/presentation/dashboard_screen/dashboard_screen.dart';
import 'package:meditrack_pro/presentation/expiry_management_screen/expiry_management_screen.dart';
import 'package:meditrack_pro/presentation/medicine_inventory_screen/medicine_inventory_screen.dart';
import 'package:meditrack_pro/presentation/sales_recording_screen/sales_recording_screen.dart';
import 'package:meditrack_pro/presentation/sales_reports_screen/sales_reports_screen.dart';
import 'package:meditrack_pro/theme/app_theme.dart';
import 'package:meditrack_pro/widgets/custom_icon_widget.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class TabProvider extends ChangeNotifier {
  int _currentIndex = 1; // default -> Inventory
  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final List<String> tabs = [
    "Dashboard",
    "Inventory",
    "Add Medicine",
    "Sales",
    "Expiry",
    "Reports"
  ];

  final List<Widget> pages = [
    DashboardScreen(),
    MedicineInventoryScreen(),
    AddMedicineScreen(),
    SalesRecordingScreen(),
    ExpiryManagementScreen(),
    SalesReportsScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MediTrack',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          CustomIconWidget(
            iconName: 'notifications',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
          SizedBox(width: 1.5.h),
          CustomIconWidget(
            iconName: 'qr_code_scanner',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 24,
          ),
          SizedBox(width: 2.h),
        ],
      ),
      body: Column(
        children: [
          // Tabs Row
          Consumer<TabProvider>(
            builder: (context, tabProvider, _) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(tabs.length, (index) {
                    final isSelected = tabProvider.currentIndex == index;
                    return GestureDetector(
                      onTap: () => tabProvider.setIndex(index),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              tabs[index],
                              style: TextStyle(
                                color: isSelected ? Colors.blue : Colors.black,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            if (isSelected)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                height: 2,
                                width: 30,
                                color: Colors.blue,
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              );
            },
          ),

          // Selected Page
          Expanded(
            child: Consumer<TabProvider>(
              builder: (context, tabProvider, _) {
                return pages[tabProvider.currentIndex];
              },
            ),
          ),
        ],
      ),
    );
  }
}
