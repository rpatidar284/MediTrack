// lib/presentation/add_medicine_screen/add_medicine_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meditrack_pro/controller/add_medicine_controller.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';
import '../../core/app_export.dart';
import './widgets/medicine_form_widget.dart';

class AddMedicineScreen extends StatelessWidget {
  const AddMedicineScreen({Key? key}) : super(key: key);

  void _showSuccessDialog(BuildContext context, String medicineName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const CustomIconWidget(
              iconName: 'check_circle',
              color: AppTheme.successLight,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'Success!',
              style: AppTheme.lightTheme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Text(
          '$medicineName has been added to inventory.',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(ctx); // Close the Add Medicine screen
              Navigator.pushNamed(
                  ctx, AppRoutes.medicineInventory); // Navigate to inventory
            },
            child: const Text('View Inventory'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(ctx);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddMedicineController(),
      child: Consumer<AddMedicineController>(
        builder: (context, controller, child) {
          return Scaffold(
            backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
            body: Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MedicineFormWidget(
                        nameController: controller.nameController,
                        batchController: controller.batchController,
                        quantityController: controller.quantityController,
                        mrpController: controller.mrpController,
                        selectedExpiryDate: controller.selectedExpiryDate,
                        selectedCategory: controller.selectedCategory,
                        onExpiryDateChanged: controller.setSelectedExpiryDate,
                        onCategoryChanged: controller.setSelectedCategory,
                        onAddAnother: controller.toggleAddAnother,
                        addAnotherEnabled: controller.addAnotherEnabled,
                      ),
                      SizedBox(height: 6.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.isLoading
                              ? null
                              : () async {
                                  await controller.saveMedicine(context);
                                  if (!controller.addAnotherEnabled &&
                                      !controller.isLoading) {
                                    _showSuccessDialog(context,
                                        controller.nameController.text);
                                  }
                                },
                          child: Text(
                            'Save Medicine',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppTheme.lightTheme.colorScheme.primary,
                            padding: EdgeInsets.symmetric(vertical: 4.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
                if (controller.isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: AppTheme.lightTheme.colorScheme.primary,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Saving medicine...',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
