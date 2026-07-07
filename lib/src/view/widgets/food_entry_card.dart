import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/food_entry.dart';
import 'meal_row.dart';

class FoodEntryCard extends StatelessWidget {
  const FoodEntryCard({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  final FoodEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_month,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      Formatters.longDate(entry.date),
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'edit') onEdit();
                      if (value == 'delete') onDelete();
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),

              MealRow(
                icon: Icons.wb_sunny,
                iconColor: AppColors.warning,
                label: 'Morning',
                meal: entry.morningMeal,
                price: entry.morningPrice,
              ),
              MealRow(
                icon: Icons.wb_sunny_outlined,
                iconColor: AppColors.warning,
                label: 'Afternoon',
                meal: entry.afternoonMeal,
                price: entry.afternoonPrice,
              ),
              MealRow(
                icon: Icons.nightlight_round,
                iconColor: AppColors.primary,
                label: 'Night',
                meal: entry.nightMeal,
                price: entry.nightPrice,
              ),

              const Divider(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Price',
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    Formatters.rupees(entry.total),
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
