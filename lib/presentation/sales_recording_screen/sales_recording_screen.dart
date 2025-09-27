// lib/presentation/sales_recording_screen/sales_recording_screen.dart
import 'package:flutter/material.dart';
import 'package:meditrack_pro/controller/sales_recording_controller.dart';
import 'package:meditrack_pro/presentation/sales_recording_screen/widgets/medicine_search_widget.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';
import './widgets/customer_info_widget.dart';
import './widgets/payment_section_widget.dart';
import './widgets/selected_medicine_card.dart';

class SalesRecordingScreen extends StatelessWidget {
  const SalesRecordingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SalesRecordingController(),
      child: Consumer<SalesRecordingController>(
        builder: (context, controller, child) {
          return Scaffold(
            backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Customer Information
                        CustomerInfoWidget(
                          nameController: controller.customerNameController,
                          phoneController: controller.customerPhoneController,
                        ),

                        // Medicine Search
                        MedicineSearchWidget(
                          searchController: controller.searchController,
                          onScanPressed:
                              () {}, // TODO: Implement barcode scanner
                          onSearchChanged: controller.searchMedicines,
                          searchResults: controller.searchResults,
                          onMedicineSelected: controller.addMedicine,
                        ),

                        // Selected Medicines
                        if (controller.selectedMedicines.isNotEmpty) ...[
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 4.w, vertical: 1.h),
                            child: Row(
                              children: [
                                Text(
                                  'Selected Medicines (${controller.selectedMedicines.length})',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.selectedMedicines.length,
                            itemBuilder: (context, index) {
                              final medicine =
                                  controller.selectedMedicines[index];
                              return SelectedMedicineCard(
                                medicine: medicine,
                                onQuantityChanged: (quantity) => controller
                                    .updateMedicineQuantity(index, quantity),
                                onRemove: () =>
                                    controller.removeMedicine(index),
                                onPriceAdjust:
                                    () {}, // TODO: Implement price adjustment logic
                              );
                            },
                          ),
                        ],

                        // Payment Section
                        if (controller.selectedMedicines.isNotEmpty)
                          PaymentSectionWidget(
                            subtotal: controller.subtotal,
                            discount: controller.discount,
                            tax: controller.tax,
                            total: controller.total,
                            selectedPaymentMethod:
                                controller.selectedPaymentMethod,
                            onPaymentMethodChanged: controller.setPaymentMethod,
                            onDiscountChanged: (value) => controller
                                .discountController.text = value.toString(),
                            notesController: controller.notesController,
                          ),

                        SizedBox(height: 10.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: controller.selectedMedicines.isNotEmpty
                ? Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.lightTheme.colorScheme.shadow
                              .withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Amount',
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '\$${controller.total.toStringAsFixed(2)}',
                                style: AppTheme
                                    .lightTheme.textTheme.headlineSmall
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          SizedBox(
                            width: double.infinity,
                            height: 6.h,
                            child: ElevatedButton(
                              onPressed: controller.isProcessing
                                  ? null
                                  : () => controller.completeSale(context),
                              child: controller.isProcessing
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    AppTheme.lightTheme
                                                        .colorScheme.onPrimary),
                                          ),
                                        ),
                                        SizedBox(width: 3.w),
                                        const Text('Processing...'),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const CustomIconWidget(
                                          iconName: 'shopping_cart_checkout',
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        SizedBox(width: 2.w),
                                        const Text('Complete Sale'),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }
}
