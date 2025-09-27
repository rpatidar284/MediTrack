import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ExpiryTimelineSelector extends StatelessWidget {
  final String selectedTimeline;
  final Function(String) onTimelineChanged;

  const ExpiryTimelineSelector({
    Key? key,
    required this.selectedTimeline,
    required this.onTimelineChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> timelineOptions = [
      {'label': '1 Month', 'value': '1_month', 'color': AppTheme.errorLight},
      {
        'label': '3 Months',
        'value': '3_months',
        'color': AppTheme.warningLight
      },
      {
        'label': '6 Months',
        'value': '6_months',
        'color': AppTheme.successLight
      },
    ];

    return Container(
      height: 9.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        children: timelineOptions.map((option) {
          final bool isSelected = selectedTimeline == option['value'];
          return Expanded(
            child: GestureDetector(
              onTap: () => onTimelineChanged(option['value']),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 2.w),
                padding: EdgeInsets.symmetric(vertical: 1.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? option['color'].withOpacity(0.2)
                      : AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? option['color'].withOpacity(0.1)
                        : AppTheme.lightTheme.colorScheme.outline,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 3.w,
                      height: 3.w,
                      decoration: BoxDecoration(
                        color: option['color'],
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      option['label'],
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
