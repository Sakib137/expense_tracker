import 'dart:math';
import 'package:flutter/material.dart';
import 'package:expense_tracker/models/budget_item.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/utils/currency_formatter.dart';
import 'package:expense_tracker/widgets/common/custom_card.dart';

class OverallBudgetCard extends StatelessWidget {
  final double spent;
  final double limit;
  final String currencySymbol;
  final BudgetStatus status;
  final VoidCallback onEditBudget;

  const OverallBudgetCard({
    super.key,
    required this.spent,
    required this.limit,
    required this.currencySymbol,
    required this.status,
    required this.onEditBudget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = limit > 0 ? (spent / limit) : 0.0;
    final progress = min(1.0, ratio);
    final remaining = max(0.0, limit - spent);
    final isExceeded = status == BudgetStatus.exceeded;
    final isWarning = status == BudgetStatus.warning;

    final statusColor = isExceeded
        ? AppColors.expense
        : isWarning
            ? AppColors.warning
            : AppColors.income;

    final statusLabel = isExceeded
        ? 'Exceeded'
        : isWarning
            ? 'Warning (>80%)'
            : 'On Track';

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Overall Monthly Budget',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Big spent vs limit summary
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                CurrencyFormatter.format(spent, symbol: currencySymbol),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'of ${CurrencyFormatter.format(limit, symbol: currencySymbol)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const Spacer(),
              Text(
                '${(ratio * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Animated Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 12,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Remaining / Overspent Pill & Edit action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isExceeded
                    ? 'Over budget by ${CurrencyFormatter.format(spent - limit, symbol: currencySymbol)}'
                    : '${CurrencyFormatter.format(remaining, symbol: currencySymbol)} remaining',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isExceeded ? AppColors.expense : AppColors.income,
                ),
              ),
              OutlinedButton.icon(
                onPressed: onEditBudget,
                icon: const Icon(Icons.edit_rounded, size: 14),
                label: const Text('Edit Budget'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(0, 32),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
