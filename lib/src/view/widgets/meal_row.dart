import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';

class MealRow extends StatelessWidget {
  const MealRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.meal,
    required this.price,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String meal;
  final double price;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Text(':  '),
          Expanded(
            child: Text(
              meal.isEmpty ? '—' : meal,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            Formatters.rupees(price),
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
