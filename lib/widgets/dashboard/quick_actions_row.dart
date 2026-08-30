import 'package:flutter/material.dart';
import 'package:expense_tracker/theme/app_colors.dart';

class QuickActionsRow extends StatelessWidget {
  final VoidCallback onAddExpense;
  final VoidCallback onAddIncome;
  final VoidCallback onSetBudget;
  final VoidCallback onViewAnalytics;

  const QuickActionsRow({
    super.key,
    required this.onAddExpense,
    required this.onAddIncome,
    required this.onSetBudget,
    required this.onViewAnalytics,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ActionButton(
            label: 'Expense',
            icon: Icons.remove_rounded,
            color: AppColors.expense,
            onTap: onAddExpense,
          ),
          _ActionButton(
            label: 'Income',
            icon: Icons.add_rounded,
            color: AppColors.income,
            onTap: onAddIncome,
          ),
          _ActionButton(
            label: 'Budget',
            icon: Icons.pie_chart_outline_rounded,
            color: AppColors.warning,
            onTap: onSetBudget,
          ),
          _ActionButton(
            label: 'Analytics',
            icon: Icons.insights_rounded,
            color: AppColors.primary,
            onTap: onViewAnalytics,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
