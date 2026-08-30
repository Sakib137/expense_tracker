import 'package:flutter/material.dart';
import 'package:expense_tracker/state/app_state.dart';
import 'package:expense_tracker/models/transaction_item.dart';
import 'package:expense_tracker/theme/app_colors.dart';

class TransactionFilters extends StatelessWidget {
  final TransactionType? selectedType;
  final DateRangeFilter selectedDateFilter;
  final String? selectedCategoryId;
  final SortOption selectedSortOption;
  final ValueChanged<TransactionType?> onTypeChanged;
  final ValueChanged<DateRangeFilter> onDateFilterChanged;
  final VoidCallback onSelectCustomDateRange;
  final VoidCallback onOpenSortSheet;
  final VoidCallback onOpenCategoryFilterSheet;

  const TransactionFilters({
    super.key,
    required this.selectedType,
    required this.selectedDateFilter,
    required this.selectedCategoryId,
    required this.selectedSortOption,
    required this.onTypeChanged,
    required this.onDateFilterChanged,
    required this.onSelectCustomDateRange,
    required this.onOpenSortSheet,
    required this.onOpenCategoryFilterSheet,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          // Sort Button
          OutlinedButton.icon(
            onPressed: onOpenSortSheet,
            icon: const Icon(Icons.sort_rounded, size: 16),
            label: Text(_getSortLabel(selectedSortOption)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(0, 36),
            ),
          ),
          const SizedBox(width: 8),

          // Type Chips: All
          _FilterChip(
            label: 'All',
            isSelected: selectedType == null,
            onSelected: () => onTypeChanged(null),
          ),
          const SizedBox(width: 6),

          // Type Chips: Expenses
          _FilterChip(
            label: 'Expenses',
            isSelected: selectedType == TransactionType.expense,
            selectedColor: AppColors.expense,
            onSelected: () => onTypeChanged(
              selectedType == TransactionType.expense ? null : TransactionType.expense,
            ),
          ),
          const SizedBox(width: 6),

          // Type Chips: Income
          _FilterChip(
            label: 'Income',
            isSelected: selectedType == TransactionType.income,
            selectedColor: AppColors.income,
            onSelected: () => onTypeChanged(
              selectedType == TransactionType.income ? null : TransactionType.income,
            ),
          ),
          const SizedBox(width: 8),

          // Category Filter
          OutlinedButton.icon(
            onPressed: onOpenCategoryFilterSheet,
            icon: const Icon(Icons.category_rounded, size: 16),
            label: Text(selectedCategoryId == null ? 'Categories' : 'Category (1)'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(0, 36),
              foregroundColor: selectedCategoryId != null ? AppColors.primary : null,
              side: selectedCategoryId != null
                  ? const BorderSide(color: AppColors.primary, width: 1.5)
                  : null,
            ),
          ),
          const SizedBox(width: 8),

          // Date Filter: This Month
          _FilterChip(
            label: 'This Month',
            isSelected: selectedDateFilter == DateRangeFilter.thisMonth,
            onSelected: () => onDateFilterChanged(
              selectedDateFilter == DateRangeFilter.thisMonth
                  ? DateRangeFilter.all
                  : DateRangeFilter.thisMonth,
            ),
          ),
          const SizedBox(width: 6),

          // Date Filter: This Week
          _FilterChip(
            label: 'This Week',
            isSelected: selectedDateFilter == DateRangeFilter.thisWeek,
            onSelected: () => onDateFilterChanged(
              selectedDateFilter == DateRangeFilter.thisWeek
                  ? DateRangeFilter.all
                  : DateRangeFilter.thisWeek,
            ),
          ),
          const SizedBox(width: 6),

          // Date Filter: Today
          _FilterChip(
            label: 'Today',
            isSelected: selectedDateFilter == DateRangeFilter.today,
            onSelected: () => onDateFilterChanged(
              selectedDateFilter == DateRangeFilter.today
                  ? DateRangeFilter.all
                  : DateRangeFilter.today,
            ),
          ),
          const SizedBox(width: 6),

          // Custom Date Range
          _FilterChip(
            label: 'Custom Range',
            isSelected: selectedDateFilter == DateRangeFilter.custom,
            onSelected: onSelectCustomDateRange,
          ),
        ],
      ),
    );
  }

  String _getSortLabel(SortOption option) {
    switch (option) {
      case SortOption.dateDesc:
        return 'Newest';
      case SortOption.dateAsc:
        return 'Oldest';
      case SortOption.amountDesc:
        return 'Highest \$';
      case SortOption.amountAsc:
        return 'Lowest \$';
      case SortOption.titleAsc:
        return 'A-Z';
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? selectedColor;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.selectedColor,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = selectedColor ?? theme.colorScheme.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.15)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? activeColor : theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }
}
