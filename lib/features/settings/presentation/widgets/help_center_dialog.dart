import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HelpCenterDialog extends StatelessWidget {
  const HelpCenterDialog({super.key});

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
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.help_outline_rounded, color: Colors.blue, size: 24),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Help Center', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      Text('Find answers and get support', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Frequently Asked Questions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 16),
                  _buildFaqItem(
                    'How do I add an appliance?',
                    'Go to the Appliances page and click "Add Appliance".',
                  ),
                  const SizedBox(height: 12),
                  _buildFaqItem(
                    'How do I track maintenance?',
                    'Use the Maintenance section to create and schedule tasks.',
                  ),
                  const SizedBox(height: 12),
                  _buildFaqItem(
                    'What is the Health Score?',
                    'It measures how well your home is maintained based on overdue tasks, expired warranties, and more.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Need more help?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  const Text(
                    'Reach out via the Contact Us page or email support@homebase.app',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
            children: [
              const TextSpan(text: '— '),
              TextSpan(text: answer),
            ],
          ),
        ),
      ],
    );
  }
}
