import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/animated_gradient_background.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/utility_providers.dart';
import '../../domain/models/utility.dart';
import '../widgets/add_utility_bottom_sheet.dart';

class UtilityScreen extends ConsumerWidget {
  const UtilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final utilitiesAsync = ref.watch(utilitiesProvider);

    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Utilities', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _showSmartCategorize(context),
                    icon: const Icon(Icons.auto_awesome, size: 16),
                    label: const Text('Smart Categorize'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: BorderSide(color: AppColors.textHint.withOpacity(0.3)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _showAddUtility(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Utility'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: utilitiesAsync.when(
          data: (utilities) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Manage your home utility accounts', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                const SizedBox(height: 24),
                _buildTotalSummary(utilities),
                const SizedBox(height: 32),
                utilities.isEmpty
                    ? _buildEmptyState(context)
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: utilities.length,
                        itemBuilder: (context, index) => _buildUtilityCard(context, ref, utilities[index]),
                      ),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildTotalSummary(List<Utility> utilities) {
    final total = utilities.fold(0.0, (sum, item) => sum + item.monthlyCost);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.attach_money, color: Colors.orange, size: 28),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const Text('Total Monthly Utilities', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUtilityCard(BuildContext context, WidgetRef ref, Utility utility) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(_getUtilityIcon(utility.type), color: Colors.orange, size: 18),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _showAddUtility(context, utility),
                icon: const Icon(Icons.edit_outlined, size: 18),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
              IconButton(
                onPressed: () => ref.read(utilityNotifierProvider.notifier).deleteUtility(utility.id),
                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(utility.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1),
          Text(utility.type, style: TextStyle(color: AppColors.textSecondary.withOpacity(0.7), fontSize: 11)),
          const Spacer(),
          Text('Provider: ${utility.provider}', style: TextStyle(color: AppColors.textSecondary.withOpacity(0.7), fontSize: 11)),
          const SizedBox(height: 4),
          Text('\$${utility.monthlyCost.toStringAsFixed(2)}/month', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green)),
        ],
      ),
    );
  }

  IconData _getUtilityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'water': return Icons.water_drop_rounded;
      case 'gas': return Icons.local_fire_department_rounded;
      case 'electricity': return Icons.bolt_rounded;
      case 'internet': return Icons.wifi_rounded;
      default: return Icons.bolt_rounded;
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Icon(Icons.power_rounded, size: 80, color: AppColors.textHint.withOpacity(0.3)),
          const SizedBox(height: 20),
          const Text('No utilities set up yet', style: TextStyle(color: AppColors.textSecondary, fontSize: 18)),
          const SizedBox(height: 12),
           ElevatedButton(onPressed: () => _showAddUtility(context), child: const Text('Add your first utility')),
        ],
      ),
    );
  }

  void _showAddUtility(BuildContext context, [Utility? utility]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddUtilityBottomSheet(utility: utility),
    );
  }

  void _showSmartCategorize(BuildContext context) {
     showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.purpleAccent),
            const SizedBox(width: 12),
            const Text('Smart Categorize'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Describe your utility bill'),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'e.g., Home Electricity bill \$100/month',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent.withOpacity(0.5)),
            child: const Text('Categorize'),
          ),
        ],
      ),
    );
  }
}
