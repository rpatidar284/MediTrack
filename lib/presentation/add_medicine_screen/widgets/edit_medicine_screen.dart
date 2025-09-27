// lib/presentation/medicine_inventory_screen/edit_medicine_screen.dart

import 'package:flutter/material.dart';
import 'package:meditrack_pro/controller/edit_medicine_controller.dart';
import 'package:meditrack_pro/presentation/add_medicine_screen/widgets/medicine_form_widget.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../core/models/medicine_model.dart';

class EditMedicineScreen extends StatelessWidget {
  final MedicineModel medicine;

  const EditMedicineScreen({Key? key, required this.medicine})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditMedicineController(medicine),
      child: Consumer<EditMedicineController>(
        builder: (context, controller, child) {
          return Scaffold(
            backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
            appBar: AppBar(
              title: const Text('Edit Medicine'),
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: CustomIconWidget(
                  iconName: 'close',
                  color: AppTheme.lightTheme.appBarTheme.foregroundColor,
                  size: 24,
                ),
              ),
            ),
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
                        onAddAnother: () {}, // Not needed for editing
                        addAnotherEnabled: false, // Not needed for editing
                      ),
                      SizedBox(height: 6.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.isLoading
                              ? null
                              : () => controller.saveChanges(context),
                          child: Text(
                            'Save Changes',
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
                              'Saving changes...',
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
