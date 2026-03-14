import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AboutAppDialog extends StatelessWidget {
  const AboutAppDialog({super.key});

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
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.info_outline_rounded, color: Colors.teal, size: 24),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('About HomeBase', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      Text('Your smart home management companion', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
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
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.home_rounded, color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 16),
                  const Text('HomeBase v1.0', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const Text('All-in-one home management', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'HomeBase helps you stay on top of everything in your home — from appliance warranties and maintenance schedules to important documents, vehicles, subscriptions, and emergency contacts.\n\nBuilt with care to keep your home running smoothly.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.6),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Version 1.0.0', style: TextStyle(color: AppColors.textHint, fontSize: 12)),
                const Text('© 2026 HomeBase', style: TextStyle(color: AppColors.textHint, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
