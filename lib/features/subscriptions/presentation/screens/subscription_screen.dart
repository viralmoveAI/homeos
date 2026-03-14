import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../shared/widgets/animated_gradient_background.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/subscription_providers.dart';
import '../../domain/models/subscription.dart';

import '../widgets/add_subscription_bottom_sheet.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionsAsync = ref.watch(subscriptionsProvider);

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
          title: const Text('Subscriptions', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
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
                    onPressed: () => _showAddSubscription(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Subscription'),
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
        body: subscriptionsAsync.when(
          data: (subscriptions) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Track your recurring expenses', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                const SizedBox(height: 24),
                _buildSummaryCards(subscriptions),
                const SizedBox(height: 32),
                if (subscriptions.where((s) => s.isActive).isNotEmpty) ...[
                  Text('Active (${subscriptions.where((s) => s.isActive).length})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  ...subscriptions.where((s) => s.isActive).map((sub) => _buildSubscriptionCard(context, ref, sub)),
                ],
                const SizedBox(height: 32),
                if (subscriptions.where((s) => !s.isActive).isNotEmpty) ...[
                  Text('Inactive (${subscriptions.where((s) => !s.isActive).length})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  ...subscriptions.where((s) => !s.isActive).map((sub) => _buildSubscriptionCard(context, ref, sub)),
                ],
                if (subscriptions.isEmpty) _buildEmptyState(),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(List<Subscription> subs) {
    final monthlyTotal = subs.where((s) => s.isActive).fold(0.0, (sum, item) => sum + item.amount);
    final yearlyTotal = monthlyTotal * 12;

    return Row(
      children: [
        Expanded(child: _buildSummaryCard('\$${monthlyTotal.toStringAsFixed(2)}', 'Monthly Total', Icons.attach_money, Colors.green)),
        const SizedBox(width: 16),
        Expanded(child: _buildSummaryCard('\$${yearlyTotal.toStringAsFixed(0)}', 'Yearly Total', Icons.trending_up, Colors.orange)),
        const SizedBox(width: 16),
        Expanded(child: _buildSummaryCard('${subs.where((s) => s.isActive).length}', 'Active Subscriptions', Icons.credit_card, Colors.blue)),
      ],
    );
  }

  Widget _buildSummaryCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          Text(label, style: TextStyle(fontSize: 12, color: AppColors.textSecondary.withOpacity(0.7))),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(BuildContext context, WidgetRef ref, Subscription sub) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.credit_card, color: Colors.blueAccent),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(sub.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(width: 8),
                          Text(sub.category, style: TextStyle(color: AppColors.textSecondary.withOpacity(0.7), fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('\$${sub.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 12, color: AppColors.textSecondary.withOpacity(0.6)),
                          const SizedBox(width: 4),
                          Text('Next billing: ${DateFormat('M/d/yyyy').format(sub.nextRenewalDate)}',
                              style: TextStyle(color: AppColors.textSecondary.withOpacity(0.6), fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => _showAddSubscription(context, sub),
                          icon: const Icon(Icons.edit_outlined, size: 20),
                        ),
                        IconButton(
                          onPressed: () => ref.read(subscriptionNotifierProvider.notifier).deleteSubscription(sub.id),
                          icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: AppColors.backgroundLight, borderRadius: BorderRadius.circular(8)),
                      child: Text(sub.billingCycle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textHint)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Icon(Icons.sync_rounded, size: 80, color: AppColors.textHint.withOpacity(0.3)),
          const SizedBox(height: 20),
          Text(
            'No subscriptions yet',
            style: TextStyle(color: AppColors.textSecondary.withOpacity(0.7), fontSize: 18),
          ),
        ],
      ),
    );
  }

  void _showAddSubscription(BuildContext context, [Subscription? subscription]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddSubscriptionBottomSheet(subscription: subscription),
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
            const Text('Describe your expense'),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'e.g., Netflix streaming service \$15/month',
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
