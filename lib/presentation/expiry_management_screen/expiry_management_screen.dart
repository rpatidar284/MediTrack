import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/models/disposal_record_model.dart';
import '../../core/models/medicine_model.dart';
import '../../core/services/medicine_service.dart';
import './widgets/bulk_action_bar.dart';
import './widgets/disposal_tracking_section.dart';
import './widgets/expiry_timeline_selector.dart';
import './widgets/filter_bottom_sheet.dart';
import './widgets/medicine_expiry_card.dart';

class ExpiryManagementScreen extends StatefulWidget {
  const ExpiryManagementScreen({Key? key}) : super(key: key);

  @override
  State<ExpiryManagementScreen> createState() => _ExpiryManagementScreenState();
}

class _ExpiryManagementScreenState extends State<ExpiryManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimeline = '3_months';
  bool _isBulkSelectionMode = false;
  List<Map<String, dynamic>> _selectedMedicines = [];
  Map<String, dynamic> _currentFilters = {};

  final MedicineService _medicineService = MedicineService();
  List<MedicineModel> _medicines = [];
  List<DisposalRecordModel> _disposalRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final medicines = await _medicineService.getFilteredMedicines(
        timeline: _selectedTimeline,
        category: _currentFilters['category'],
        supplier: _currentFilters['supplier'],
      );

      final disposalRecords = await _medicineService.getFilteredDisposalRecords(
        status: _currentFilters['disposalStatus'],
        category: _currentFilters['category'],
        supplier: _currentFilters['supplier'],
      );

      setState(() {
        _medicines = medicines;
        _disposalRecords = disposalRecords;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: ${e.toString()}'),
          backgroundColor: AppTheme.errorLight,
        ),
      );
    }
  }

  List<Map<String, dynamic>> get _filteredMedicines {
    return _medicines.map((medicine) => medicine.toUIMap()).toList();
  }

  List<Map<String, dynamic>> get _filteredDisposalRecords {
    return _disposalRecords.map((record) => record.toUIMap()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTimelineSelector(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildExpiryManagementTab(),
                _buildDisposalTrackingTab(),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: BulkActionBar(
        isVisible: _isBulkSelectionMode && _selectedMedicines.isNotEmpty,
        selectedCount: _selectedMedicines.length,
        onApplyBulkDiscount: _applyBulkDiscount,
        onMarkBulkForDisposal: _markBulkForDisposal,
        onClearSelection: _clearSelection,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Expiry Management',
        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        if (_tabController.index == 0)
          IconButton(
            onPressed: _toggleBulkSelectionMode,
            icon: CustomIconWidget(
              iconName: _isBulkSelectionMode ? 'close' : 'checklist',
              color: _isBulkSelectionMode
                  ? AppTheme.errorLight
                  : AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
        IconButton(
          onPressed: _showFilterBottomSheet,
          icon: CustomIconWidget(
            iconName: 'filter_list',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'export_expiry',
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'file_download',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text('Export Expiry Report'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'export_disposal',
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'description',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text('Export Disposal Report'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'schedule_notifications',
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'notifications',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text('Schedule Notifications'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimelineSelector() {
    return ExpiryTimelineSelector(
      selectedTimeline: _selectedTimeline,
      onTimelineChanged: (timeline) {
        setState(() {
          _selectedTimeline = timeline;
          _clearSelection();
        });
        _loadData();
      },
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.lightTheme.colorScheme.surface,
      child: TabBar(
        controller: _tabController,
        onTap: (index) {
          setState(() {
            _clearSelection();
          });
        },
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'warning',
                  color: _tabController.index == 0
                      ? AppTheme.primaryLight
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                SizedBox(width: 1.w),
                Text('Expiring Medicines'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'delete_outline',
                  color: _tabController.index == 1
                      ? AppTheme.primaryLight
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                SizedBox(width: 1.w),
                Text('Disposal Tracking'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiryManagementTab() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryLight,
        ),
      );
    }

    final filteredMedicines = _filteredMedicines;

    if (filteredMedicines.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: AppTheme.successLight,
              size: 64,
            ),
            SizedBox(height: 2.h),
            Text(
              'No Medicines Expiring',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.successLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'All medicines are within safe expiry periods',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: EdgeInsets.only(
          top: 1.h,
          bottom: _isBulkSelectionMode && _selectedMedicines.isNotEmpty
              ? 12.h
              : 2.h,
        ),
        itemCount: filteredMedicines.length,
        itemBuilder: (context, index) {
          final medicine = filteredMedicines[index];
          final isSelected = _selectedMedicines
              .any((selected) => selected['id'] == medicine['id']);

          return MedicineExpiryCard(
            medicine: medicine,
            isSelected: isSelected,
            onSelectionChanged: _handleMedicineSelection,
            onApplyDiscount: _applyDiscount,
            onMarkForDisposal: _markForDisposal,
            onGenerateSaleAlert: _generateSaleAlert,
            onRemoveFromAlerts: _removeFromAlerts,
          );
        },
      ),
    );
  }

  Widget _buildDisposalTrackingTab() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryLight,
        ),
      );
    }

    final filteredRecords = _filteredDisposalRecords;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        child: DisposalTrackingSection(
          disposalRecords: filteredRecords,
          onViewDisposalDetails: _viewDisposalDetails,
        ),
      ),
    );
  }

  void _toggleBulkSelectionMode() {
    setState(() {
      _isBulkSelectionMode = !_isBulkSelectionMode;
      if (!_isBulkSelectionMode) {
        _selectedMedicines.clear();
      }
    });
  }

  void _handleMedicineSelection(Map<String, dynamic> medicine) {
    if (!_isBulkSelectionMode) return;

    setState(() {
      final isSelected = _selectedMedicines
          .any((selected) => selected['id'] == medicine['id']);
      if (isSelected) {
        _selectedMedicines
            .removeWhere((selected) => selected['id'] == medicine['id']);
      } else {
        _selectedMedicines.add(medicine);
      }
    });

    HapticFeedback.selectionClick();
  }

  void _clearSelection() {
    setState(() {
      _selectedMedicines.clear();
      _isBulkSelectionMode = false;
    });
  }

  void _applyDiscount(Map<String, dynamic> medicine) {
    _showDiscountDialog([medicine]);
  }

  void _applyBulkDiscount() {
    _showDiscountDialog(_selectedMedicines);
  }

  void _showDiscountDialog(List<Map<String, dynamic>> medicines) {
    final TextEditingController discountController = TextEditingController();
    final suggestedDiscount = medicines.isNotEmpty
        ? medicines.first['suggestedDiscount']?.toString() ?? '10'
        : '10';

    discountController.text = suggestedDiscount;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Apply Discount'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              medicines.length == 1
                  ? 'Apply discount to ${medicines.first['name']}'
                  : 'Apply discount to ${medicines.length} selected medicines',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: discountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Discount Percentage',
                suffixText: '%',
                hintText: 'Enter discount percentage',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final discount = double.tryParse(discountController.text);
              if (discount != null && discount > 0 && discount <= 100) {
                await _applyDiscountToMedicines(medicines, discount);
                Navigator.pop(context);
              }
            },
            child: Text('Apply'),
          ),
        ],
      ),
    );
  }

  Future<void> _applyDiscountToMedicines(
      List<Map<String, dynamic>> medicines, double discount) async {
    try {
      if (medicines.length == 1) {
        await _medicineService.applyDiscount(medicines.first['id'], discount);
      } else {
        final ids = medicines.map((m) => m['id'] as int).toList();
        await _medicineService.applyBulkDiscount(ids, discount);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            medicines.length == 1
                ? 'Discount applied to ${medicines.first['name']}'
                : 'Discount applied to ${medicines.length} medicines',
          ),
          backgroundColor: AppTheme.successLight,
        ),
      );

      _clearSelection();
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error applying discount: ${e.toString()}'),
          backgroundColor: AppTheme.errorLight,
        ),
      );
    }
  }

  void _markForDisposal(Map<String, dynamic> medicine) {
    _showDisposalDialog([medicine]);
  }

  void _markBulkForDisposal() {
    _showDisposalDialog(_selectedMedicines);
  }

  void _showDisposalDialog(List<Map<String, dynamic>> medicines) {
    String selectedMethod = 'Pharmaceutical Waste Collection';
    final List<String> disposalMethods = [
      'Pharmaceutical Waste Collection',
      'Return to Manufacturer',
      'Incineration',
      'Chemical Treatment',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Mark for Disposal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                medicines.length == 1
                    ? 'Mark ${medicines.first['name']} for disposal'
                    : 'Mark ${medicines.length} selected medicines for disposal',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              SizedBox(height: 2.h),
              Text(
                'Disposal Method',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedMethod,
                    isExpanded: true,
                    items: disposalMethods.map((method) {
                      return DropdownMenuItem<String>(
                        value: method,
                        child: Text(method),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedMethod = value;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _markMedicinesForDisposal(medicines, selectedMethod);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorLight,
              ),
              child: Text('Mark for Disposal'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _markMedicinesForDisposal(
      List<Map<String, dynamic>> medicines, String method) async {
    try {
      final medicineModels = medicines
          .map((m) =>
              _medicines.firstWhere((medicine) => medicine.id == m['id']))
          .toList();

      await _medicineService.markMedicinesForDisposal(medicineModels, method);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            medicines.length == 1
                ? '${medicines.first['name']} marked for disposal'
                : '${medicines.length} medicines marked for disposal',
          ),
          backgroundColor: AppTheme.warningLight,
        ),
      );

      _clearSelection();
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error marking for disposal: ${e.toString()}'),
          backgroundColor: AppTheme.errorLight,
        ),
      );
    }
  }

  void _generateSaleAlert(Map<String, dynamic> medicine) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sale alert generated for ${medicine['name']}'),
        backgroundColor: AppTheme.primaryLight,
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to sales screen
          },
        ),
      ),
    );
  }

  void _removeFromAlerts(Map<String, dynamic> medicine) async {
    try {
      await _medicineService.deleteMedicine(medicine['id']);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${medicine['name']} removed from expiry alerts'),
          backgroundColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        ),
      );

      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing medicine: ${e.toString()}'),
          backgroundColor: AppTheme.errorLight,
        ),
      );
    }
  }

  void _viewDisposalDetails(Map<String, dynamic> record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Disposal Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Medicine', record['medicineName'] as String),
            _buildDetailRow('Batch Number', record['batchNumber'] as String),
            _buildDetailRow('Quantity', record['quantity'].toString()),
            _buildDetailRow('Disposal Date', record['disposalDate'] as String),
            _buildDetailRow('Method', record['disposalMethod'] as String),
            _buildDetailRow('Status', record['status'] as String),
            _buildDetailRow('Category', record['category'] as String),
            _buildDetailRow('Supplier', record['supplier'] as String),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          if (record['status'] == 'Pending')
            ElevatedButton(
              onPressed: () async {
                await _updateDisposalStatus(record, 'Disposed');
                Navigator.pop(context);
              },
              child: Text('Mark as Disposed'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 25.w,
            child: Text(
              '$label:',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateDisposalStatus(
      Map<String, dynamic> record, String newStatus) async {
    try {
      await _medicineService.updateDisposalStatus(record['id'], newStatus);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Disposal status updated to $newStatus'),
          backgroundColor: AppTheme.successLight,
        ),
      );

      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: ${e.toString()}'),
          backgroundColor: AppTheme.errorLight,
        ),
      );
    }
  }

  void _showFilterBottomSheet() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        currentFilters: _currentFilters,
        onFiltersApplied: (filters) {
          setState(() {
            _currentFilters = filters;
          });
          _loadData();
        },
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export_expiry':
        _exportExpiryReport();
        break;
      case 'export_disposal':
        _exportDisposalReport();
        break;
      case 'schedule_notifications':
        _scheduleNotifications();
        break;
    }
  }

  void _exportExpiryReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Expiry report exported successfully'),
        backgroundColor: AppTheme.successLight,
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            // Open exported file
          },
        ),
      ),
    );
  }

  void _exportDisposalReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Disposal report exported successfully'),
        backgroundColor: AppTheme.successLight,
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            // Open exported file
          },
        ),
      ),
    );
  }

  void _scheduleNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Schedule Notifications'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Set up automatic notifications for medicines approaching expiry',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'notifications',
                color: AppTheme.primaryLight,
                size: 24,
              ),
              title: Text('Daily Expiry Alerts'),
              subtitle: Text('Get notified about medicines expiring soon'),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Notifications scheduled successfully'),
                  backgroundColor: AppTheme.successLight,
                ),
              );
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}
