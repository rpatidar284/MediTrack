// lib/presentation/medicine_inventory_screen/edit_medicine_controller.dart

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meditrack_pro/core/app_export.dart';
import 'package:meditrack_pro/core/models/medicine_model.dart';
import 'package:meditrack_pro/core/services/medicine_service.dart';

class EditMedicineController extends ChangeNotifier {
  final MedicineService _medicineService = MedicineService();
  final MedicineModel originalMedicine;

  late TextEditingController nameController;
  late TextEditingController batchController;
  late TextEditingController quantityController;
  late TextEditingController mrpController;

  late DateTime? _selectedExpiryDate;
  late String? _selectedCategory;
  bool _isLoading = false;

  EditMedicineController(this.originalMedicine) {
    nameController = TextEditingController(text: originalMedicine.name);
    batchController = TextEditingController(text: originalMedicine.batchNumber);
    quantityController =
        TextEditingController(text: originalMedicine.quantity.toString());
    mrpController =
        TextEditingController(text: originalMedicine.mrp.toString());
    _selectedExpiryDate = _parseDate(originalMedicine.expiryDate);
    _selectedCategory = originalMedicine.category;
  }

  DateTime? get selectedExpiryDate => _selectedExpiryDate;
  String? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;

  void setSelectedExpiryDate(DateTime? date) {
    _selectedExpiryDate = date;
    notifyListeners();
  }

  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  DateTime? _parseDate(String dateString) {
    // Assuming the date format is 'dd/MM/yyyy'
    final parts = dateString.split('/');
    if (parts.length == 3) {
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }
    return null;
  }

  void _showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.errorLight,
      textColor: Colors.white,
    );
  }

  Future<void> saveChanges(BuildContext context) async {
    // Form validation
    if (nameController.text.trim().isEmpty ||
        batchController.text.trim().isEmpty ||
        quantityController.text.trim().isEmpty ||
        double.tryParse(quantityController.text) == null ||
        double.parse(quantityController.text) <= 0 ||
        _selectedExpiryDate == null ||
        _selectedExpiryDate!.isBefore(DateTime.now()) ||
        mrpController.text.trim().isEmpty ||
        double.tryParse(mrpController.text) == null ||
        double.parse(mrpController.text) <= 0 ||
        _selectedCategory == null) {
      _showError('Please fill all required fields with valid data.');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final expiryDate = _selectedExpiryDate!;
      final daysUntilExpiry = expiryDate.difference(now).inDays;

      final updatedMedicine = originalMedicine.copyWith(
        name: nameController.text.trim(),
        batchNumber: batchController.text.trim(),
        quantity: int.parse(quantityController.text),
        mrp: double.parse(mrpController.text),
        category: _selectedCategory!,
        expiryDate: '${expiryDate.day}/${expiryDate.month}/${expiryDate.year}',
        daysUntilExpiry: daysUntilExpiry,
        updatedAt: now.toIso8601String(),
      );

      await _medicineService.updateMedicine(updatedMedicine);

      Fluttertoast.showToast(
        msg: 'Medicine updated successfully!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.successLight,
        textColor: Colors.white,
      );

      Navigator.pop(context); // Go back to the inventory screen
    } catch (e) {
      _showError('Error updating medicine: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    batchController.dispose();
    quantityController.dispose();
    mrpController.dispose();
    super.dispose();
  }
}
