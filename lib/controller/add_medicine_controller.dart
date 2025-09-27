// lib/presentation/add_medicine_screen/add_medicine_controller.dart
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meditrack_pro/core/app_export.dart';
import 'package:meditrack_pro/core/models/medicine_model.dart';
import 'package:meditrack_pro/core/services/medicine_service.dart';

class AddMedicineController extends ChangeNotifier {
  final MedicineService _medicineService = MedicineService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController batchController = TextEditingController();
  final TextEditingController quantityController =
      TextEditingController(text: '1');
  final TextEditingController mrpController = TextEditingController();

  DateTime? _selectedExpiryDate;
  String? _selectedCategory;
  bool _addAnotherEnabled = false;
  bool _isLoading = false;

  DateTime? get selectedExpiryDate => _selectedExpiryDate;
  String? get selectedCategory => _selectedCategory;
  bool get addAnotherEnabled => _addAnotherEnabled;
  bool get isLoading => _isLoading;

  void setSelectedExpiryDate(DateTime? date) {
    _selectedExpiryDate = date;
    notifyListeners();
  }

  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void toggleAddAnother() {
    _addAnotherEnabled = !_addAnotherEnabled;
    notifyListeners();
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

  Future<void> saveMedicine(BuildContext context) async {
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

      final newMedicine = MedicineModel(
        name: nameController.text.trim(),
        batchNumber: batchController.text.trim(),
        quantity: int.parse(quantityController.text),
        mrp: double.parse(mrpController.text),
        category: _selectedCategory!,
        supplier: 'Unknown Supplier', // TODO: Add supplier field to UI
        expiryDate: '${expiryDate.day}/${expiryDate.month}/${expiryDate.year}',
        daysUntilExpiry: daysUntilExpiry,
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
      );

      await _medicineService.insertMedicine(newMedicine);

      Fluttertoast.showToast(
        msg: 'Medicine added successfully!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.successLight,
        textColor: Colors.white,
      );

      if (_addAnotherEnabled) {
        clearForm();
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      _showError('Error saving medicine: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearForm() {
    nameController.clear();
    batchController.clear();
    quantityController.text = '1';
    mrpController.clear();
    _selectedExpiryDate = null;
    _selectedCategory = null;
    notifyListeners();
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
