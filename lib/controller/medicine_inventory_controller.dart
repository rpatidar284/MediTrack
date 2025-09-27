// lib/presentation/medicine_inventory_screen/medicine_inventory_controller.dart
import 'package:flutter/material.dart';
import 'package:meditrack_pro/core/models/medicine_model.dart';
import 'package:meditrack_pro/core/services/medicine_service.dart';

class MedicineInventoryController extends ChangeNotifier {
  final MedicineService _medicineService = MedicineService();
  final TextEditingController searchController = TextEditingController();

  List<MedicineModel> _allMedicines = [];
  List<MedicineModel> _filteredMedicines = [];
  bool _isLoading = false;
  Map<String, dynamic> _activeFilters = {
    'category': 'All Categories',
    'stockLevel': 'All Stock',
    'expiryFilter': 'All Medicines',
  };

  List<MedicineModel> get filteredMedicines => _filteredMedicines;
  bool get isLoading => _isLoading;
  Map<String, dynamic> get activeFilters => _activeFilters;

  MedicineInventoryController() {
    searchController.addListener(() {
      _applyFiltersWithSearch(searchController.text);
    });

    _medicineService.addListener(loadMedicines);
    loadMedicines();
  }

  @override
  void dispose() {
    _medicineService.removeListener(loadMedicines);
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadMedicines() async {
    _isLoading = true;
    notifyListeners();
    _allMedicines = await _medicineService.getAllMedicines();
    _applyFiltersWithSearch(searchController.text);
    _isLoading = false;
    notifyListeners();
  }

  void _applyFiltersWithSearch(String query) {
    List<MedicineModel> tempFiltered = _allMedicines.where((medicine) {
      final name = medicine.name.toLowerCase();
      final batch = medicine.batchNumber.toLowerCase();
      return name.contains(query.toLowerCase()) ||
          batch.contains(query.toLowerCase());
    }).toList();

    tempFiltered = tempFiltered.where((medicine) {
      bool matchesCategory = _activeFilters['category'] == 'All Categories' ||
          medicine.category == _activeFilters['category'];
      bool matchesStock = _activeFilters['stockLevel'] == 'All Stock';
      if (_activeFilters['stockLevel'] == 'In Stock') {
        matchesStock = medicine.quantity > 10;
      } else if (_activeFilters['stockLevel'] == 'Low Stock') {
        matchesStock = medicine.quantity > 0 && medicine.quantity <= 10;
      } else if (_activeFilters['stockLevel'] == 'Out of Stock') {
        matchesStock = medicine.quantity == 0;
      }
      bool matchesExpiry = _activeFilters['expiryFilter'] == 'All Medicines';
      if (_activeFilters['expiryFilter'] == 'Expired') {
        matchesExpiry = medicine.daysUntilExpiry < 0;
      } else if (_activeFilters['expiryFilter'] == 'Expiring Soon (3 months)') {
        matchesExpiry =
            medicine.daysUntilExpiry >= 0 && medicine.daysUntilExpiry <= 90;
      } else if (_activeFilters['expiryFilter'] == 'Good Stock') {
        matchesExpiry = medicine.daysUntilExpiry > 90;
      }
      return matchesCategory && matchesStock && matchesExpiry;
    }).toList();

    _filteredMedicines = tempFiltered;
    notifyListeners();
  }

  void applyFilters(Map<String, dynamic> filters) {
    _activeFilters = filters;
    _applyFiltersWithSearch(searchController.text);
  }

  Future<void> deleteMedicine(int id) async {
    await _medicineService.deleteMedicine(id);
  }

  void removeFilter(String filterKey) {
    _activeFilters[filterKey] = filterKey == 'category'
        ? 'All Categories'
        : filterKey == 'stockLevel'
            ? 'All Stock'
            : 'All Medicines';
    applyFilters(_activeFilters);
  }
}
