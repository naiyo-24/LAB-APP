import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class OrderSearchFilterCard extends StatelessWidget {
  final Function(String) onSearchChanged;
  final Function(String) onStatusFilterChanged;
  final String currentStatus;

  const OrderSearchFilterCard({
    super.key,
    required this.onSearchChanged,
    required this.onStatusFilterChanged,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Field
          TextField(
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search by customer name or phone no',
              prefixIcon: const Icon(IconsaxPlusLinear.search_normal),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          const SizedBox(height: 16),
          // Status Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                'All',
                'pending',
                'accepted',
                'sample_collected',
                'testing_in_progress',
                'report_ready',
                'completed',
                'cancelled'
              ].map((status) {
                final isSelected = currentStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(
                      status.replaceAll('_', ' ').toUpperCase(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        onStatusFilterChanged(status);
                      }
                    },
                    backgroundColor: AppColors.background,
                    selectedColor: AppColors.primary,
                    checkmarkColor: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
