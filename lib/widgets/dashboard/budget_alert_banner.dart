import 'package:flutter/material.dart';
import 'package:expense_tracker/state/app_state.dart';
import 'package:expense_tracker/models/budget_item.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/utils/currency_formatter.dart';

class BudgetAlertBanner extends StatelessWidget {
  final List<CategoryBudgetAlert> alerts;
  final String currencySymbol;
  final VoidCallback onManageBudgets;

  const BudgetAlertBanner({
    super.key,
    required this.alerts,
    required this.currencySymbol,
    required this.onManageBudgets,
  });

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();

    final hasExceeded = alerts.any((a) => a.status == BudgetStatus.exceeded);
    final alertColor = hasExceeded ? AppColors.expense : AppColors.warning;
    final topAlert = alerts.first;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: alertColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: alertColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: alertColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasExceeded ? Icons.error_outline_rounded : Icons.warning_amber_rounded,
              color: alertColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasExceeded
                      ? 'Budget Exceeded: ${topAlert.categoryName}'
                      : 'Approaching Limit: ${topAlert.categoryName}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: alertColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${CurrencyFormatter.format(topAlert.spent, symbol: currencySymbol)} spent of ${CurrencyFormatter.format(topAlert.limit, symbol: currencySymbol)} limit',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onManageBudgets,
            style: TextButton.styleFrom(
              foregroundColor: alertColor,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
            child: const Text('Manage'),
          ),
        ],
      ),
    );
  }
}
