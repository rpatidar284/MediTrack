// lib/presentation/sales_recording_screen/sales_recording_controller.dart
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../core/app_export.dart';
import '../../core/models/medicine_model.dart';
import '../../core/services/medicine_service.dart';

class SalesRecordingController extends ChangeNotifier {
  final MedicineService _medicineService = MedicineService();

  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController customerPhoneController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController discountController =
      TextEditingController(text: '0.0');

  List<MedicineModel> _allMedicines = [];
  List<MedicineModel> _searchResults = [];
  List<Map<String, dynamic>> _selectedMedicines = [];
  String _selectedPaymentMethod = 'Cash';
  bool _isProcessing = false;

  List<MedicineModel> get searchResults => _searchResults;
  List<Map<String, dynamic>> get selectedMedicines => _selectedMedicines;
  String get selectedPaymentMethod => _selectedPaymentMethod;
  bool get isProcessing => _isProcessing;

  SalesRecordingController() {
    _loadAllMedicines();
    discountController.addListener(notifyListeners);
  }

  Future<void> _loadAllMedicines() async {
    _allMedicines = await _medicineService.getAllMedicines();
    notifyListeners();
  }

  void searchMedicines(String query) {
    if (query.isEmpty) {
      _searchResults = [];
    } else {
      _searchResults = _allMedicines.where((medicine) {
        return medicine.name.toLowerCase().contains(query.toLowerCase()) ||
            medicine.batchNumber.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  void addMedicine(MedicineModel medicine) {
    final index = _selectedMedicines.indexWhere((m) => m['id'] == medicine.id);
    final availableQuantity = medicine.quantity;

    if (index != -1) {
      final currentSelectedQty =
          (_selectedMedicines[index]['selectedQuantity'] as num).toDouble();
      if (currentSelectedQty < availableQuantity) {
        _selectedMedicines[index]['selectedQuantity'] =
            currentSelectedQty + 1.0;
      } else {
        _showToast('Cannot exceed available stock of $availableQuantity');
      }
    } else {
      _selectedMedicines.add({
        'id': medicine.id,
        'name': medicine.name,
        'batch': medicine.batchNumber,
        'quantity': availableQuantity,
        'selectedQuantity': 1.0,
        'price': medicine.mrp,
      });
    }

    _searchResults = [];
    searchController.clear();
    notifyListeners();
  }

  void updateMedicineQuantity(int index, double newQuantity) {
    final availableQuantity = _selectedMedicines[index]['quantity'] as int;

    if (newQuantity <= availableQuantity && newQuantity > 0) {
      _selectedMedicines[index]['selectedQuantity'] = newQuantity;
    } else if (newQuantity > availableQuantity) {
      _showToast('Cannot exceed available stock of $availableQuantity');
    }
    notifyListeners();
  }

  void removeMedicine(int index) {
    _selectedMedicines.removeAt(index);
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  double get subtotal => _selectedMedicines.fold(0.0, (sum, item) {
        final price = (item['price'] as num?)?.toDouble() ?? 0.0;
        final quantity = (item['selectedQuantity'] as num?)?.toDouble() ?? 0.0;
        return sum + (price * quantity);
      });

  double get tax => subtotal * 0.1;
  double get discount => double.tryParse(discountController.text) ?? 0.0;
  double get total => subtotal + tax - discount;

  Future<void> completeSale(BuildContext context) async {
    if (_selectedMedicines.isEmpty) {
      _showToast('Please add medicines to the sale.');
      return;
    }

    _isProcessing = true;
    notifyListeners();

    try {
      final saleItems = _selectedMedicines.map((medicine) {
        final selectedQuantity =
            (medicine['selectedQuantity'] as num?)?.toDouble() ?? 0.0;
        final price = (medicine['price'] as num?)?.toDouble() ?? 0.0;
        final total = selectedQuantity * price;

        return {
          'id': medicine['id'],
          'name': medicine['name'],
          'batch': medicine['batch'],
          'selectedQuantity': selectedQuantity,
          'price': price,
          'total': total,
        };
      }).toList();

      await _medicineService.recordSale(
        saleItems,
        _selectedPaymentMethod,
        customerNameController.text.trim().isNotEmpty
            ? customerNameController.text.trim()
            : null,
        customerPhoneController.text.trim().isNotEmpty
            ? customerPhoneController.text.trim()
            : null,
        total,
      );

      _showSuccessDialog(context);
      resetForm();
    } catch (e) {
      _showToast('Error processing sale: $e');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            CustomIconWidget(
                iconName: 'check_circle',
                color: AppTheme.successLight,
                size: 24),
            SizedBox(width: 8),
            Text('Sale Completed'),
          ],
        ),
        content: Text('Total Amount: \$${total.toStringAsFixed(2)}'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.textPrimaryLight,
      textColor: AppTheme.surfaceLight,
    );
  }

  void resetForm() {
    _selectedMedicines.clear();
    _searchResults.clear();
    searchController.clear();
    customerNameController.clear();
    customerPhoneController.clear();
    notesController.clear();
    discountController.text = '0.0';
    _selectedPaymentMethod = 'Cash';
    _loadAllMedicines();
    notifyListeners();
  }

  @override
  void dispose() {
    customerNameController.dispose();
    customerPhoneController.dispose();
    searchController.dispose();
    notesController.dispose();
    discountController.dispose();
    super.dispose();
  }
}
