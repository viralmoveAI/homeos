import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HowToUseDialog extends StatelessWidget {
  const HowToUseDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.menu_book_outlined, color: Colors.purple, size: 24),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('How to Use HomeBase', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      Text('A quick guide to get you started', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textHint),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildStepItem(
                      '1',
                      'Set Up Your Home',
                      'Click your profile menu and set a house name to personalize your dashboard.',
                    ),
                    _buildStepItem(
                      '2',
                      'Add Your Appliances',
                      'Go to Appliances and add items with warranty dates and service intervals so you never miss a deadline.',
                    ),
                    _buildStepItem(
                      '3',
                      'Schedule Maintenance',
                      'Create maintenance tasks with priorities and due dates. Track overdue, upcoming, and completed work.',
                    ),
                    _buildStepItem(
                      '4',
                      'Store Important Documents',
                      'Use the Digital Vault to upload and organize warranties, manuals, contracts, and more.',
                    ),
                    _buildStepItem(
                      '5',
                      'Track Costs',
                      'Add your subscriptions and utilities to monitor monthly spending in one place.',
                    ),
                    _buildStepItem(
                      '6',
                      'Save Emergency Contacts',
                      'Keep plumber, electrician, and other emergency contacts handy for when you need them.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem(String number, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              number,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple, fontSize: 13),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
