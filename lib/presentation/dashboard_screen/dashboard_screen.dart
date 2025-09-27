// lib/presentation/dashboard_screen/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meditrack_pro/controller/dashboard_controller.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';
import '../../core/app_export.dart';
import './widgets/activity_item_widget.dart';
import './widgets/metric_card_widget.dart';
import './widgets/quick_action_button_widget.dart';
import './widgets/sales_chart_widget.dart';
import './widgets/sync_status_widget.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardController(),
      child: Consumer<DashboardController>(
        builder: (context, controller, child) {
          return Scaffold(
            backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
            body: RefreshIndicator(
              onRefresh: controller.loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: controller.isLoading
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 1.h),
                          // Sync Status
                          SyncStatusWidget(
                            isOnline:
                                true, // TODO: Implement real-time connectivity check
                            lastSyncTime: DateTime.now(),
                            onRefresh: controller.loadData,
                          ),
                          SizedBox(height: 2.h),
                          // Metrics Cards
                          MetricCardWidget(
                            title: 'Total Stock Value',
                            value: controller.totalStockValue,
                            subtitle:
                                'Across ${controller.totalMedicines} medicines',
                            icon: const CustomIconWidget(
                                iconName: 'inventory', size: 24),
                            onTap: () {
                              Navigator.pushNamed(
                                  context, AppRoutes.medicineInventory);
                            },
                          ),
                          SizedBox(height: 1.h),
                          MetricCardWidget(
                            title: 'Medicines Expiring Soon',
                            value: controller.expiringSoonCount.toString(),
                            subtitle: 'Within next 3 months',
                            icon: const CustomIconWidget(
                                iconName: 'warning',
                                color: AppTheme.warningLight,
                                size: 24),
                            valueColor: AppTheme.warningLight,
                            showBadge: controller.expiringSoonCount > 0,
                            badgeText: controller.expiringSoonCount.toString(),
                            onTap: () {
                              Navigator.pushNamed(
                                  context, AppRoutes.expiryManagement);
                            },
                          ),
                          SizedBox(height: 1.h),
                          MetricCardWidget(
                            title: 'Today\'s Sales',
                            value:
                                "\$${controller.todaySales.toStringAsFixed(2)}",
                            subtitle:
                                '${controller.todayTransactions} transactions completed',
                            icon: const CustomIconWidget(
                                iconName: 'trending_up',
                                color: AppTheme.successLight,
                                size: 24),
                            valueColor: AppTheme.successLight,
                            showBadge: false,
                            onTap: () {
                              Navigator.pushNamed(
                                  context, AppRoutes.salesRecording);
                            },
                          ),
                          SizedBox(height: 1.h),
                          MetricCardWidget(
                            title: 'Low Stock Alerts',
                            value: controller.lowStockCount.toString(),
                            subtitle: 'Medicines below threshold',
                            icon: const CustomIconWidget(
                                iconName: 'notifications',
                                color: AppTheme.errorLight,
                                size: 24),
                            valueColor: AppTheme.errorLight,
                            showBadge: controller.lowStockCount > 0,
                            badgeText: controller.lowStockCount.toString(),
                            onTap: () {
                              Navigator.pushNamed(
                                  context, AppRoutes.medicineInventory);
                            },
                          ),
                          SizedBox(height: 3.h),
                          // Quick Actions
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: Text(
                              'Quick Actions',
                              style: AppTheme.lightTheme.textTheme.titleLarge
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: Row(
                              children: [
                                QuickActionButtonWidget(
                                  title: 'Add Medicine',
                                  icon: const CustomIconWidget(
                                      iconName: 'add_circle',
                                      color: Colors.white,
                                      size: 24),
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, AppRoutes.addMedicine);
                                  },
                                ),
                                QuickActionButtonWidget(
                                  title: 'Record Sale',
                                  icon: const CustomIconWidget(
                                      iconName: 'point_of_sale',
                                      color: Colors.white,
                                      size: 24),
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, AppRoutes.salesRecording);
                                  },
                                  backgroundColor:
                                      AppTheme.lightTheme.colorScheme.tertiary,
                                ),
                                QuickActionButtonWidget(
                                  title: 'Scan Barcode',
                                  icon: const CustomIconWidget(
                                      iconName: 'qr_code_scanner',
                                      color: Colors.white,
                                      size: 24),
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, AppRoutes.addMedicine);
                                  },
                                  backgroundColor: AppTheme.warningLight,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 3.h),
                          // Sales Chart
                          SalesChartWidget(
                            salesData: controller.salesData,
                            selectedPeriod: controller.selectedChartPeriod,
                            onPeriodChanged: controller.onChartPeriodChanged,
                          ),
                          SizedBox(height: 3.h),
                          // Recent Activity
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: Text(
                              'Recent Activity',
                              style: AppTheme.lightTheme.textTheme.titleLarge
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          ...controller.recentActivities
                              .map((activity) => ActivityItemWidget(
                                    title: activity['title'] as String,
                                    description:
                                        activity['description'] as String,
                                    timestamp: activity['timestamp'] as String,
                                    icon: CustomIconWidget(
                                      iconName: activity['icon'] as String,
                                      color: AppTheme.lightTheme.colorScheme
                                          .primary, // Placeholder color
                                      size: 20,
                                    ),
                                    iconBackgroundColor: AppTheme.lightTheme
                                        .colorScheme.primaryContainer,
                                  ))
                              .toList(),
                          SizedBox(height: 10.h),
                        ],
                      ),
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(context, '/add-medicine-screen');
              },
              icon: CustomIconWidget(
                iconName: 'qr_code_scanner',
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                size: 20,
              ),
              label: Text(
                'Quick Scan',
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
            ),
          );
        },
      ),
    );
  }
}
