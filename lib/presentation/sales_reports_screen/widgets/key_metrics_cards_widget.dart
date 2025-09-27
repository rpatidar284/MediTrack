import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class KeyMetricsCardsWidget extends StatelessWidget {
  final Map<String, dynamic> metricsData;

  const KeyMetricsCardsWidget({
    Key? key,
    required this.metricsData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> metrics = [
      {
        'title': 'Total Sales',
        'value':
            '\$${(metricsData['totalSales'] as double).toStringAsFixed(2)}',
        'icon': 'trending_up',
        'color': AppTheme.lightTheme.primaryColor,
        'change': '+12.5%',
        'isPositive': true,
      },
      {
        'title': 'Profit Margin',
        'value':
            '${(metricsData['profitMargin'] as double).toStringAsFixed(1)}%',
        'icon': 'account_balance_wallet',
        'color': AppTheme.successLight,
        'change': '+2.3%',
        'isPositive': true,
      },
      {
        'title': 'Transactions',
        'value': (metricsData['transactionCount'] as int).toString(),
        'icon': 'receipt_long',
        'color': AppTheme.warningLight,
        'change': '+8.7%',
        'isPositive': true,
      },
    ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(metrics[0]),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildMetricCard(metrics[1]),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        _buildMetricCard(metrics[2]),
      ],
    );
  }

  Widget _buildMetricCard(Map<String, dynamic> metric) {
    return Container(
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
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: (metric['color'] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: metric['icon'] as String,
                  color: metric['color'] as Color,
                  size: 20,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: (metric['isPositive'] as bool)
                      ? AppTheme.successLight.withValues(alpha: 0.1)
                      : AppTheme.errorLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  metric['change'] as String,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: (metric['isPositive'] as bool)
                        ? AppTheme.successLight
                        : AppTheme.errorLight,
                    fontWeight: FontWeight.w600,
                    fontSize: 9.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            metric['value'] as String,
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            metric['title'] as String,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
