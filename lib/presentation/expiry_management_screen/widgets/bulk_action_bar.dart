import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BulkActionBar extends StatelessWidget {
  final bool isVisible;
  final int selectedCount;
  final VoidCallback onApplyBulkDiscount;
  final VoidCallback onMarkBulkForDisposal;
  final VoidCallback onClearSelection;

  const BulkActionBar({
    Key? key,
    required this.isVisible,
    required this.selectedCount,
    required this.onApplyBulkDiscount,
    required this.onMarkBulkForDisposal,
    required this.onClearSelection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Container(
      height: 10.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$selectedCount items selected',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: onClearSelection,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Clear selection',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: onApplyBulkDiscount,
                    icon: CustomIconWidget(
                      iconName: 'local_offer',
                      color: Colors.white,
                      size: 18,
                    ),
                    label: Text('Apply Discount'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryLight,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  ElevatedButton.icon(
                    onPressed: onMarkBulkForDisposal,
                    icon: CustomIconWidget(
                      iconName: 'delete_outline',
                      color: Colors.white,
                      size: 18,
                    ),
                    label: Text('Mark for Disposal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorLight,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
