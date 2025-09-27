// lib/presentation/medicine_inventory_screen/medicine_inventory_screen.dart

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meditrack_pro/controller/medicine_inventory_controller.dart';
import 'package:meditrack_pro/presentation/add_medicine_screen/widgets/edit_medicine_screen.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';
import '../../core/app_export.dart';
import '../../core/models/medicine_model.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/filter_chip_widget.dart';
import './widgets/medicine_card_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/skeleton_loading_widget.dart';

class MedicineInventoryScreen extends StatefulWidget {
  const MedicineInventoryScreen({Key? key}) : super(key: key);

  @override
  State<MedicineInventoryScreen> createState() =>
      _MedicineInventoryScreenState();
}

class _MedicineInventoryScreenState extends State<MedicineInventoryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openEditScreen(BuildContext context, MedicineModel medicine) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMedicineScreen(medicine: medicine),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MedicineInventoryController(),
      child: Consumer<MedicineInventoryController>(
        builder: (context, controller, child) {
          return Scaffold(
            backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
            body: Column(
              children: [
                SearchBarWidget(
                  controller: controller.searchController,
                  onChanged: (value) {},
                  onFilterTap: () =>
                      _showFilterBottomSheet(context, controller),
                ),
                if (_buildActiveFilterChips(controller).isNotEmpty)
                  Container(
                    height: 6.h,
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _buildActiveFilterChips(controller),
                    ),
                  ),
                Expanded(
                  child: controller.isLoading
                      ? const SkeletonLoadingWidget()
                      : controller.filteredMedicines.isEmpty
                          ? EmptyStateWidget(
                              title: (controller
                                          .searchController.text.isNotEmpty ||
                                      _hasActiveFilters(controller))
                                  ? 'No medicines found'
                                  : 'No medicines in inventory',
                              subtitle: (controller
                                          .searchController.text.isNotEmpty ||
                                      _hasActiveFilters(controller))
                                  ? 'Try adjusting your search or filters'
                                  : 'Start by adding your first medicine to the inventory',
                              buttonText: 'Add First Medicine',
                              onButtonPressed: () {
                                Navigator.pushNamed(
                                    context, AppRoutes.addMedicine);
                              },
                            )
                          : RefreshIndicator(
                              onRefresh: controller.loadMedicines,
                              child: ListView.builder(
                                itemCount: controller.filteredMedicines.length,
                                itemBuilder: (context, index) {
                                  final medicine =
                                      controller.filteredMedicines[index];
                                  return MedicineCardWidget(
                                    medicine: medicine,
                                    onEdit: () => _openEditScreen(context,
                                        medicine), // Call the new edit function
                                    onDelete: () => _showDeleteConfirmation(
                                        context, controller, medicine),
                                  );
                                },
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

  bool _hasActiveFilters(MedicineInventoryController controller) {
    return controller.activeFilters['category'] != 'All Categories' ||
        controller.activeFilters['stockLevel'] != 'All Stock' ||
        controller.activeFilters['expiryFilter'] != 'All Medicines';
  }

  List<Widget> _buildActiveFilterChips(MedicineInventoryController controller) {
    List<Widget> chips = [];
    controller.activeFilters.forEach((key, value) {
      if (value != 'All Categories' &&
          value != 'All Stock' &&
          value != 'All Medicines') {
        chips.add(
          FilterChipWidget(
            label: value,
            count: controller.filteredMedicines.length,
            onRemove: () => controller.removeFilter(key),
          ),
        );
      }
    });
    return chips;
  }

  void _showFilterBottomSheet(
      BuildContext context, MedicineInventoryController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => FilterBottomSheetWidget(
        currentFilters: controller.activeFilters,
        onApplyFilters: (filters) => controller.applyFilters(filters),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context,
      MedicineInventoryController controller, MedicineModel medicine) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Medicine'),
        content: Text('Are you sure you want to delete ${medicine.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await controller.deleteMedicine(medicine.id!);
              Fluttertoast.showToast(
                msg: "${medicine.name} deleted successfully",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },
            child: const Text('Delete',
                style: TextStyle(color: AppTheme.errorLight)),
          ),
        ],
      ),
    );
  }
}
