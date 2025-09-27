// lib/presentation/medicine_inventory_screen/widgets/medicine_card_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../core/models/medicine_model.dart';

class MedicineCardWidget extends StatelessWidget {
  final MedicineModel medicine;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onSale;
  final VoidCallback? onDiscount;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;
  final VoidCallback? onMoveToCategory;
  final VoidCallback? onPrintLabel;

  const MedicineCardWidget({
    Key? key,
    required this.medicine,
    this.onTap,
    this.onEdit,
    this.onSale,
    this.onDiscount,
    this.onDelete,
    this.onDuplicate,
    this.onMoveToCategory,
    this.onPrintLabel,
  }) : super(key: key);

  Color _getStatusColor() {
    if (medicine.daysUntilExpiry < 0) {
      return AppTheme.errorLight;
    } else if (medicine.daysUntilExpiry <= 90) {
      return AppTheme.warningLight;
    } else {
      return AppTheme.successLight;
    }
  }

  String _getStatusText() {
    if (medicine.daysUntilExpiry < 0) {
      return 'Expired';
    } else if (medicine.daysUntilExpiry <= 90) {
      return 'Expiring Soon';
    } else {
      return 'Unexpired';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final isLowStock = medicine.quantity <= 10 && medicine.quantity > 0;
    final isOutOfStock = medicine.quantity == 0;
    final displayPrice = medicine.mrp;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Slidable(
        key: ValueKey(medicine.id),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onEdit?.call(),
              backgroundColor: AppTheme.lightTheme.primaryColor,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
              borderRadius: BorderRadius.circular(12),
            ),
            SlidableAction(
              onPressed: (_) => onSale?.call(),
              backgroundColor: AppTheme.successLight,
              foregroundColor: Colors.white,
              icon: Icons.shopping_cart,
              label: 'Sale',
              borderRadius: BorderRadius.circular(12),
            ),
            SlidableAction(
              onPressed: (_) => onDiscount?.call(),
              backgroundColor: AppTheme.warningLight,
              foregroundColor: Colors.white,
              icon: Icons.local_offer,
              label: 'Discount',
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onDelete?.call(),
              backgroundColor: AppTheme.errorLight,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: onTap,
          onLongPress: () => _showContextMenu(context),
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicine.name,
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        const CustomIconWidget(
                          iconName: 'qr_code',
                          color: AppTheme.textSecondaryLight,
                          size: 16,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Batch: ${medicine.batchNumber}',
                          style: AppTheme.lightTheme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        const CustomIconWidget(
                          iconName: 'inventory',
                          color: AppTheme.textSecondaryLight,
                          size: 16,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Qty: ${medicine.quantity} units',
                          style: AppTheme.lightTheme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'MRP: \$${displayPrice.toStringAsFixed(2)}',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        color: AppTheme.lightTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _getStatusText(),
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 1.5.h),
                    Row(
                      children: [
                        const CustomIconWidget(
                          iconName: 'calendar_today',
                          color: AppTheme.textSecondaryLight,
                          size: 16,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Exp: ${medicine.expiryDate}',
                          style: AppTheme.lightTheme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    SizedBox(height: 1.5.h),
                    if (isLowStock)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: AppTheme.warningLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Low Stock',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme.warningLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    if (isOutOfStock)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: AppTheme.errorLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Out of Stock',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme.errorLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              margin: EdgeInsets.symmetric(vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const CustomIconWidget(
                iconName: 'content_copy',
                color: AppTheme.primaryLight,
                size: 24,
              ),
              title: const Text('Duplicate Entry'),
              onTap: () {
                Navigator.pop(context);
                onDuplicate?.call();
              },
            ),
            ListTile(
              leading: const CustomIconWidget(
                iconName: 'category',
                color: AppTheme.primaryLight,
                size: 24,
              ),
              title: const Text('Move to Category'),
              onTap: () {
                Navigator.pop(context);
                onMoveToCategory?.call();
              },
            ),
            ListTile(
              leading: const CustomIconWidget(
                iconName: 'print',
                color: AppTheme.primaryLight,
                size: 24,
              ),
              title: const Text('Print Label'),
              onTap: () {
                Navigator.pop(context);
                onPrintLabel?.call();
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
