import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double radius;
  final Color backgroundColor;

  const UserAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.radius = 20.0,
    this.backgroundColor = AppColors.primaryBlue,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(imageUrl!),
        backgroundColor: Colors.grey[200],
      );
    }
    
    // Fallback to initial
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }
}
