import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MedicineExpiryCard extends StatelessWidget {
  final Map<String, dynamic> medicine;
  final Function(Map<String, dynamic>) onApplyDiscount;
  final Function(Map<String, dynamic>) onMarkForDisposal;
  final Function(Map<String, dynamic>) onGenerateSaleAlert;
  final Function(Map<String, dynamic>) onRemoveFromAlerts;
  final bool isSelected;
  final Function(Map<String, dynamic>) onSelectionChanged;

  const MedicineExpiryCard({
    Key? key,
    required this.medicine,
    required this.onApplyDiscount,
    required this.onMarkForDisposal,
    required this.onGenerateSaleAlert,
    required this.onRemoveFromAlerts,
    required this.isSelected,
    required this.onSelectionChanged,
  }) : super(key: key);

  Color _getUrgencyColor(int daysUntilExpiry) {
    if (daysUntilExpiry < 0) return AppTheme.errorLight;
    if (daysUntilExpiry <= 30) return AppTheme.warningLight;
    if (daysUntilExpiry <= 90) return Colors.orange;
    return AppTheme.successLight;
  }

  String _getUrgencyText(int daysUntilExpiry) {
    if (daysUntilExpiry < 0) return 'Expired ${daysUntilExpiry.abs()} days ago';
    if (daysUntilExpiry == 0) return 'Expires today';
    return 'Expires in $daysUntilExpiry days';
  }

  @override
  Widget build(BuildContext context) {
    final int daysUntilExpiry = medicine['daysUntilExpiry'] as int;
    final Color urgencyColor = _getUrgencyColor(daysUntilExpiry);
    final bool hasDiscount = medicine['discountPercentage'] != null &&
        medicine['discountPercentage'] > 0;
    final double originalPrice = (medicine['mrp'] as num).toDouble();
    final double discountedPrice = hasDiscount
        ? originalPrice * (1 - (medicine['discountPercentage'] as num) / 100)
        : originalPrice;

    return Slidable(
      key: ValueKey(medicine['id']),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onApplyDiscount(medicine),
            backgroundColor: AppTheme.primaryLight,
            foregroundColor: Colors.white,
            icon: Icons.local_offer,
            label: 'Discount',
          ),
          SlidableAction(
            onPressed: (_) => onMarkForDisposal(medicine),
            backgroundColor: AppTheme.errorLight,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: 'Dispose',
          ),
          SlidableAction(
            onPressed: (_) => onGenerateSaleAlert(medicine),
            backgroundColor: AppTheme.warningLight,
            foregroundColor: Colors.white,
            icon: Icons.notifications_active,
            label: 'Alert',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onRemoveFromAlerts(medicine),
            backgroundColor: AppTheme.lightTheme.colorScheme.outline,
            foregroundColor: Colors.white,
            icon: Icons.remove_circle_outline,
            label: 'Remove',
          ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? AppTheme.primaryLight : Colors.transparent,
              width: isSelected ? 2 : 0,
            ),
          ),
          child: InkWell(
            onTap: () => onSelectionChanged(medicine),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (isSelected)
                        Container(
                          margin: EdgeInsets.only(right: 2.w),
                          child: CustomIconWidget(
                            iconName: 'check_circle',
                            color: AppTheme.primaryLight,
                            size: 20,
                          ),
                        ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              medicine['name'] as String,
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              'Batch: ${medicine['batchNumber']}',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: urgencyColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: urgencyColor, width: 1),
                        ),
                        child: Text(
                          _getUrgencyText(daysUntilExpiry),
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: urgencyColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quantity: ${medicine['quantity']}',
                              style: AppTheme.lightTheme.textTheme.bodyMedium,
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              'Expiry: ${medicine['expiryDate']}',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (hasDiscount) ...[
                            Text(
                              '\$${originalPrice.toStringAsFixed(2)}',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '\$${discountedPrice.toStringAsFixed(2)}',
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                color: AppTheme.successLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 1.5.w, vertical: 0.25.h),
                              decoration: BoxDecoration(
                                color: AppTheme.successLight
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${medicine['discountPercentage']}% OFF',
                                style: AppTheme.lightTheme.textTheme.labelSmall
                                    ?.copyWith(
                                  color: AppTheme.successLight,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ] else ...[
                            Text(
                              '\$${originalPrice.toStringAsFixed(2)}',
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (medicine['suggestedDiscount'] != null)
                              Container(
                                margin: EdgeInsets.only(top: 0.5.h),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 1.5.w, vertical: 0.25.h),
                                decoration: BoxDecoration(
                                  color: AppTheme.warningLight
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Suggested: ${medicine['suggestedDiscount']}% OFF',
                                  style: AppTheme
                                      .lightTheme.textTheme.labelSmall
                                      ?.copyWith(
                                    color: AppTheme.warningLight,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
