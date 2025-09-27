import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MedicineFormWidget extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController batchController;
  final TextEditingController quantityController;
  final TextEditingController mrpController;
  final DateTime? selectedExpiryDate;
  final String? selectedCategory;
  final Function(DateTime?) onExpiryDateChanged;
  final Function(String?) onCategoryChanged;
  final VoidCallback onAddAnother;
  final bool addAnotherEnabled;

  const MedicineFormWidget({
    Key? key,
    required this.nameController,
    required this.batchController,
    required this.quantityController,
    required this.mrpController,
    required this.selectedExpiryDate,
    required this.selectedCategory,
    required this.onExpiryDateChanged,
    required this.onCategoryChanged,
    required this.onAddAnother,
    required this.addAnotherEnabled,
  }) : super(key: key);

  @override
  State<MedicineFormWidget> createState() => _MedicineFormWidgetState();
}

class _MedicineFormWidgetState extends State<MedicineFormWidget> {
  final List<String> _medicineSuggestions = [
    'Paracetamol 500mg',
    'Aspirin 75mg',
    'Ibuprofen 400mg',
    'Amoxicillin 250mg',
    'Cetirizine 10mg',
    'Omeprazole 20mg',
    'Metformin 500mg',
    'Atorvastatin 10mg',
    'Lisinopril 5mg',
    'Amlodipine 5mg',
    'Losartan 50mg',
    'Simvastatin 20mg',
    'Levothyroxine 50mcg',
    'Gabapentin 300mg',
    'Prednisone 5mg',
  ];

  final List<String> _categories = [
    'Analgesics',
    'Antibiotics',
    'Antihistamines',
    'Antacids',
    'Antidiabetics',
    'Cardiovascular',
    'Respiratory',
    'Dermatological',
    'Gastrointestinal',
    'Neurological',
    'Vitamins & Supplements',
    'Hormones',
    'Anti-inflammatory',
    'Antiseptics',
    'Others',
  ];

  int _currentQuantity = 1;

  @override
  void initState() {
    super.initState();
    if (widget.quantityController.text.isNotEmpty) {
      _currentQuantity = int.tryParse(widget.quantityController.text) ?? 1;
    }
  }

  void _updateQuantity(int value) {
    setState(() {
      _currentQuantity = value;
      widget.quantityController.text = _currentQuantity.toString();
    });
  }

  Future<void> _selectExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedExpiryDate ??
          DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: AppTheme.lightTheme.colorScheme),
          child: child!,
        );
      },
    );

    if (picked != null) {
      widget.onExpiryDateChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMedicineNameField(),
        SizedBox(height: 3.h),
        _buildBatchNumberField(),
        SizedBox(height: 3.h),
        _buildQuantitySection(),
        SizedBox(height: 3.h),
        _buildExpiryDateField(),
        SizedBox(height: 3.h),
        _buildMRPField(),
        SizedBox(height: 3.h),
        _buildCategoryField(),
        SizedBox(height: 4.h),
        _buildAddAnotherToggle(),
      ],
    );
  }

  Widget _buildMedicineNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Medicine Name *',
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return _medicineSuggestions.where((String option) {
              return option.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  );
            });
          },
          onSelected: (String selection) {
            widget.nameController.text = selection;
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            controller.text = widget.nameController.text;
            controller.addListener(() {
              widget.nameController.text = controller.text;
            });

            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: 'Enter medicine name',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'medication',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ),
              textCapitalization: TextCapitalization.words,
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 30.h, maxWidth: 85.w),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        dense: true,
                        title: Text(
                          option,
                          style: AppTheme.lightTheme.textTheme.bodyMedium,
                        ),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBatchNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Batch Number *',
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: widget.batchController,
          decoration: InputDecoration(
            hintText: 'Enter batch number',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'qr_code',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
          ),
          textCapitalization: TextCapitalization.characters,
        ),
      ],
    );
  }

  Widget _buildQuantitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quantity *',
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: widget.quantityController,
                decoration: InputDecoration(
                  hintText: 'Enter quantity',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'inventory',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                onChanged: (value) {
                  final quantity = int.tryParse(value) ?? 1;
                  setState(() {
                    _currentQuantity = quantity;
                  });
                },
              ),
            ),
            SizedBox(width: 3.w),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_currentQuantity > 0.5) {
                        _updateQuantity(_currentQuantity - 1);
                      }
                    },
                    child: Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(7),
                          bottomLeft: Radius.circular(7),
                        ),
                      ),
                      child: CustomIconWidget(
                        iconName: 'remove',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 18,
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 12.w,
                    color: AppTheme.lightTheme.colorScheme.outline,
                  ),
                  GestureDetector(
                    onTap: () {
                      _updateQuantity(_currentQuantity + 1);
                    },
                    child: Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(7),
                          bottomRight: Radius.circular(7),
                        ),
                      ),
                      child: CustomIconWidget(
                        iconName: 'add',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpiryDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expiry Date *',
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        GestureDetector(
          onTap: _selectExpiryDate,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.inputDecorationTheme.fillColor,
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'calendar_today',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    widget.selectedExpiryDate != null
                        ? '${widget.selectedExpiryDate!.day}/${widget.selectedExpiryDate!.month}/${widget.selectedExpiryDate!.year}'
                        : 'Select expiry date',
                    style: widget.selectedExpiryDate != null
                        ? AppTheme.lightTheme.textTheme.bodyMedium
                        : AppTheme.lightTheme.inputDecorationTheme.hintStyle,
                  ),
                ),
                CustomIconWidget(
                  iconName: 'arrow_drop_down',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMRPField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MRP *',
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: widget.mrpController,
          decoration: InputDecoration(
            hintText: 'Enter MRP',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'attach_money',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category *',
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        DropdownSearch<String>(
          items: _categories,
          selectedItem: widget.selectedCategory,
          onChanged: widget.onCategoryChanged,
          dropdownDecoratorProps: DropDownDecoratorProps(
            // <-- lowercase d
            dropdownSearchDecoration: InputDecoration(
              // <-- use dropdownSearchDecoration
              hintText: 'Select category',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'category',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
            ),
          ),
          popupProps: PopupProps.menu(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: 'Search categories...',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'search',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ),
            ),
            menuProps: MenuProps(
              borderRadius: BorderRadius.circular(8),
              elevation: 4,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildAddAnotherToggle() {
    return Row(
      children: [
        Switch(
          value: widget.addAnotherEnabled,
          onChanged: (_) => widget.onAddAnother(),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Text(
            'Add Another Medicine',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
