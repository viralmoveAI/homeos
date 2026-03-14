import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final pastelColor = _getPastelColor();
    final darkColor = _getDarkColor();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: pastelColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: darkColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: darkColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: darkColor.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPastelColor() {
    if (title.contains('Overdue')) return Colors.red.shade50;
    if (title.contains('Upcoming')) return Colors.orange.shade50;
    if (title.contains('Completed')) return Colors.green.shade50;
    return AppColors.surfaceWhite;
  }

  Color _getDarkColor() {
    if (title.contains('Overdue')) return Colors.red.shade900;
    if (title.contains('Upcoming')) return Colors.orange.shade900;
    if (title.contains('Completed')) return Colors.green.shade900;
    return color;
  }
}
