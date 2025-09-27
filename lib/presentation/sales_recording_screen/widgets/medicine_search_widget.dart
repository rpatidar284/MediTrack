// lib/presentation/sales_recording_screen/widgets/medicine_search_widget.dart
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../core/models/medicine_model.dart';

class MedicineSearchWidget extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onScanPressed;
  final Function(String) onSearchChanged;
  final List<MedicineModel> searchResults;
  final Function(MedicineModel) onMedicineSelected;

  const MedicineSearchWidget({
    Key? key,
    required this.searchController,
    required this.onScanPressed,
    required this.onSearchChanged,
    required this.searchResults,
    required this.onMedicineSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
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
            'Medicine Selection',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    labelText: 'Search Medicine',
                    hintText: 'Enter medicine name or batch',
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(3.w),
                      child: CustomIconWidget(
                        iconName: 'search',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.5.h,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Container(
                height: 6.h,
                width: 12.w,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: InkWell(
                  onTap: onScanPressed,
                  borderRadius: BorderRadius.circular(8),
                  child: const Center(
                    child: CustomIconWidget(
                      iconName: 'qr_code_scanner',
                      color: AppTheme.onPrimaryLight,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (searchResults.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Container(
              constraints: BoxConstraints(maxHeight: 20.h),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final medicine = searchResults[index];
                  return ListTile(
                    title: Text(
                      medicine.name,
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                    subtitle: Text(
                      'Batch: ${medicine.batchNumber} | Available: ${medicine.quantity}',
                      style: AppTheme.lightTheme.textTheme.bodySmall,
                    ),
                    trailing: Text(
                      '\$${medicine.mrp.toStringAsFixed(2)}',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () => onMedicineSelected(medicine),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
