import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PaymentSectionWidget extends StatelessWidget {
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final String selectedPaymentMethod;
  final Function(String) onPaymentMethodChanged;
  final Function(double) onDiscountChanged;
  final TextEditingController notesController;

  const PaymentSectionWidget({
    Key? key,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    required this.selectedPaymentMethod,
    required this.onPaymentMethodChanged,
    required this.onDiscountChanged,
    required this.notesController,
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
            'Payment Details',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),

          // Payment Method Selection
          Text(
            'Payment Method',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              _buildPaymentMethodChip(
                  'Cash', 'payments', selectedPaymentMethod == 'Cash'),
              SizedBox(width: 2.w),
              _buildPaymentMethodChip(
                  'Card', 'credit_card', selectedPaymentMethod == 'Card'),
              SizedBox(width: 2.w),
              _buildPaymentMethodChip(
                  'UPI', 'qr_code', selectedPaymentMethod == 'UPI'),
            ],
          ),

          SizedBox(height: 3.h),

          // Discount Section
          Row(
            children: [
              Expanded(
                child: Text(
                  'Discount',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                width: 25.w,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '0.00',
                    prefixText: '\$ ',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.h,
                    ),
                  ),
                  onChanged: (value) {
                    final discountValue = double.tryParse(value) ?? 0.0;
                    onDiscountChanged(discountValue);
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Bill Summary
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primaryContainer
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildBillRow('Subtotal', subtotal),
                _buildBillRow('Discount', -discount),
                _buildBillRow(
                    'Tax (${(tax / subtotal * 100).toStringAsFixed(1)}%)', tax),
                Divider(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  thickness: 1,
                ),
                _buildBillRow('Total', total, isTotal: true),
              ],
            ),
          ),

          SizedBox(height: 2.h),

          // Notes Section
          TextFormField(
            controller: notesController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Notes (Optional)',
              hintText: 'Add transaction notes...',
              alignLabelWithHint: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 4.w,
                vertical: 1.5.h,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodChip(
      String method, String iconName, bool isSelected) {
    return Expanded(
      child: InkWell(
        onTap: () => onPaymentMethodChanged(method),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1.5.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.surface,
            border: Border.all(
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.outline,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              CustomIconWidget(
                iconName: iconName,
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.onPrimary
                    : AppTheme.lightTheme.colorScheme.onSurface,
                size: 20,
              ),
              SizedBox(height: 0.5.h),
              Text(
                method,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.onPrimary
                      : AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBillRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  )
                : AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: isTotal
                ? AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  )
                : AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
          ),
        ],
      ),
    );
  }
}
