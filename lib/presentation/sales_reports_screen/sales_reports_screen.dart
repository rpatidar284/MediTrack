// lib/presentation/sales_reports_screen/sales_reports_screen.dart

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meditrack_pro/controller/sales_reports_controller.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';

import '../../core/app_export.dart';
import './widgets/date_range_selector_widget.dart';
import './widgets/export_options_widget.dart';
import './widgets/key_metrics_cards_widget.dart';
import './widgets/report_type_selector_widget.dart';
import './widgets/sales_summary_chart_widget.dart';
import './widgets/top_selling_medicines_widget.dart';

class SalesReportsScreen extends StatefulWidget {
  const SalesReportsScreen({Key? key}) : super(key: key);

  @override
  State<SalesReportsScreen> createState() => _SalesReportsScreenState();
}

class _SalesReportsScreenState extends State<SalesReportsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SalesReportsController(),
      child: Consumer<SalesReportsController>(
        builder: (context, controller, child) {
          return Scaffold(
            backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
            body: RefreshIndicator(
              onRefresh: () => controller.loadData(),
              color: AppTheme.lightTheme.primaryColor,
              child: TabBarView(
                controller: _tabController,
                children: [
                  SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DateRangeSelectorWidget(
                          selectedRange: controller.selectedDateRange,
                          onRangeChanged: controller.onDateRangeChanged,
                          onCustomRangeSelected:
                              controller.onCustomRangeSelected,
                        ),
                        SizedBox(height: 2.h),
                        ReportTypeSelectorWidget(
                          selectedType: controller.selectedReportType,
                          onTypeChanged: controller.onReportTypeChanged,
                        ),
                        SizedBox(height: 2.h),
                        controller.isLoading
                            ? Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  child: CircularProgressIndicator(
                                    color: AppTheme.lightTheme.primaryColor,
                                  ),
                                ),
                              )
                            : _buildReportContent(context, controller),
                        SizedBox(height: 2.h),
                        ExportOptionsWidget(
                          onExportPDF: () => _exportToPDF(context),
                          onExportExcel: () => _exportToExcel(context),
                        ),
                        SizedBox(height: 2.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReportContent(
      BuildContext context, SalesReportsController controller) {
    switch (controller.selectedReportType) {
      case 'sales_summary':
        final data = controller.reportData['sales_summary'] ?? {};
        return Column(
          children: [
            KeyMetricsCardsWidget(metricsData: data),
            SizedBox(height: 2.h),
            SalesSummaryChartWidget(salesData: data['salesData'] ?? []),
            SizedBox(height: 2.h),
            TopSellingMedicinesWidget(
                medicinesData: controller.reportData['top_selling'] ?? []),
          ],
        );
      case 'product_performance':
        final data = controller.reportData['product_performance'] ?? [];
        return _buildProductPerformanceContent(data);
      case 'profit_analysis':
        final data = controller.reportData['profit_analysis'] ?? {};
        return _buildProfitAnalysisContent(data);
      case 'inventory_turnover':
        final data = controller.reportData['inventory_turnover'] ?? {};
        return _buildInventoryTurnoverContent(data);
      default:
        return Container();
    }
  }

  Widget _buildProductPerformanceContent(List<Map<String, dynamic>> data) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Product Performance',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              CustomIconWidget(
                iconName: 'search',
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
                size: 20,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.length,
            separatorBuilder: (context, index) => Divider(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.2),
              height: 2.h,
            ),
            itemBuilder: (context, index) {
              final product = data[index];
              return Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['name'] as String,
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          product['category'] as String,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${product['unitsSold']} units',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          '\$${(product['revenue'] as double).toStringAsFixed(2)}',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.successLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfitAnalysisContent(Map<String, dynamic> data) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profit Analysis',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                    child: _buildProfitMetric(
                      'Total Revenue',
                      '\$${(data['totalRevenue'] as double).toStringAsFixed(0)}',
                      AppTheme.lightTheme.primaryColor,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: _buildProfitMetric(
                      'Net Profit',
                      '\$${(data['netProfit'] as double).toStringAsFixed(0)}',
                      AppTheme.successLight,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                'Cost Breakdown',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 1.h),
              ...((data['costBreakdown'] as List).map((cost) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 1.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        cost['category'] as String,
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '\$${(cost['amount'] as double).toStringAsFixed(0)} (${(cost['percentage'] as double).toStringAsFixed(0)}%)',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfitMetric(String title, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryTurnoverContent(Map<String, dynamic> data) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Inventory Turnover Analysis',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildTurnoverMetric(
                  'Turnover Rate',
                  '${(data['turnoverRate'] as double).toStringAsFixed(1)}x',
                  'per year',
                  AppTheme.lightTheme.primaryColor,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildTurnoverMetric(
                  'Avg Days to Sell',
                  (data['avgDaysToSell'] as double).toStringAsFixed(0),
                  'days',
                  AppTheme.warningLight,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Category Performance',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          ...((data['categoryPerformance'] as List).map((cat) {
            return _buildCategoryItem(
              cat['category'] as String,
              '${(cat['turnover'] as double).toStringAsFixed(1)}x',
              AppTheme.successLight, // Color logic is simplified
            );
          }).toList()),
        ],
      ),
    );
  }

  Widget _buildTurnoverMetric(
      String title, String value, String unit, Color color) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 0.5.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 1.w),
              Text(
                unit,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: color.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String category, String turnover, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            category,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              turnover,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _exportToPDF(BuildContext context) {
    Fluttertoast.showToast(
      msg: "Exporting to PDF...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _exportToExcel(BuildContext context) {
    Fluttertoast.showToast(
      msg: "Exporting to Excel...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }
}
