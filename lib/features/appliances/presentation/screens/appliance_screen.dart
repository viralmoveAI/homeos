import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/animated_gradient_background.dart';
import '../../domain/models/appliance.dart';
import '../providers/appliance_providers.dart';
import '../widgets/add_appliance_bottom_sheet.dart';

class ApplianceScreen extends ConsumerStatefulWidget {
  const ApplianceScreen({super.key});

  @override
  ConsumerState<ApplianceScreen> createState() => _ApplianceScreenState();
}

class _ApplianceScreenState extends ConsumerState<ApplianceScreen> {
  String _searchQuery = '';
  ApplianceCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final appliancesAsync = ref.watch(appliancesProvider);

    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Appliances', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: ElevatedButton.icon(
                onPressed: () => _showAddAppliance(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Appliance'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
              child: Text(
                'Manage and track all your home appliances',
                style: TextStyle(color: AppColors.textSecondary.withOpacity(0.8), fontSize: 15),
              ),
            ),
            _buildSearchBar(),
            _buildCategoryFilters(),
            Expanded(
              child: appliancesAsync.when(
                data: (appliances) {
                  final filtered = appliances.where((a) {
                    final matchesSearch = a.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        a.brand.toLowerCase().contains(_searchQuery.toLowerCase());
                    final matchesCategory = _selectedCategory == null || a.category == _selectedCategory;
                    return matchesSearch && matchesCategory;
                  }).toList();

                  if (filtered.isEmpty) {
                    return _buildEmptyState();
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return _buildApplianceCard(filtered[index]);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
        ),
        child: TextField(
          onChanged: (v) => setState(() => _searchQuery = v),
          decoration: const InputDecoration(
            hintText: 'Search appliances...',
            prefixIcon: Icon(Icons.search, color: AppColors.textHint),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          _buildFilterChip(null, 'All Categories'),
          ...ApplianceCategory.values.map((c) => _buildFilterChip(c, c.displayName)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(ApplianceCategory? category, String label) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (v) => setState(() => _selectedCategory = v ? category : null),
        backgroundColor: Colors.white.withOpacity(0.5),
        selectedColor: AppColors.primaryBlue.withOpacity(0.2),
        checkmarkColor: AppColors.primaryBlue,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide.none),
      ),
    );
  }

  Widget _buildApplianceCard(Appliance appliance) {
    final isWarrantyActive = appliance.warrantyExpiry != null && appliance.warrantyExpiry!.isAfter(DateTime.now());

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_getCategoryIcon(appliance.category), size: 20, color: AppColors.primaryBlue),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                          onPressed: () => _showEditAppliance(context, appliance),
                          visualDensity: VisualDensity.compact,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                          onPressed: () => _deleteAppliance(appliance),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  appliance.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                  Text(
                    'Brand: ${appliance.brand}',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary.withOpacity(0.7)),
                    maxLines: 1,
                  ),
                const Spacer(),
                if (appliance.location.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(appliance.location, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                const SizedBox(height: 4),
                if (appliance.warrantyExpiry != null)
                  Text(
                    'Warranty: ${isWarrantyActive ? 'Active' : 'Expired'}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isWarrantyActive ? Colors.green : Colors.red,
                    ),
                  ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    appliance.category.displayName,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textHint),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(ApplianceCategory category) {
    switch (category) {
      case ApplianceCategory.kitchen: return Icons.kitchen;
      case ApplianceCategory.laundry: return Icons.local_laundry_service;
      case ApplianceCategory.hvac: return Icons.ac_unit;
      case ApplianceCategory.entertainment: return Icons.tv;
      case ApplianceCategory.cleaning: return Icons.cleaning_services;
      case ApplianceCategory.other: return Icons.settings_input_component;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.kitchen_outlined, size: 80, color: AppColors.textHint.withOpacity(0.3)),
          const SizedBox(height: 20),
          const Text('No appliances found', style: TextStyle(color: AppColors.textHint, fontSize: 18)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: () => _showAddAppliance(context), child: const Text('Add your first appliance')),
        ],
      ),
    );
  }

  void _showAddAppliance(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddApplianceBottomSheet(),
    );
  }

  void _showEditAppliance(BuildContext context, Appliance appliance) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddApplianceBottomSheet(appliance: appliance),
    );
  }

  void _deleteAppliance(Appliance appliance) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Appliance'),
        content: Text('Are you sure you want to delete ${appliance.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(applianceNotifierProvider.notifier).deleteAppliance(appliance.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
