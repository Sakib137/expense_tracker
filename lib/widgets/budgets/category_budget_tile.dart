import 'dart:math';
import 'package:flutter/material.dart';
import 'package:expense_tracker/models/category_item.dart';
import 'package:expense_tracker/models/budget_item.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/utils/currency_formatter.dart';
import 'package:expense_tracker/widgets/common/custom_card.dart';

class CategoryBudgetTile extends StatelessWidget {
  final CategoryItem category;
  final double spent;
  final double limit;
  final String currencySymbol;
  final BudgetStatus status;
  final VoidCallback onEdit;

  const CategoryBudgetTile({
    super.key,
    required this.category,
    required this.spent,
    required this.limit,
    required this.currencySymbol,
    required this.status,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = limit > 0 ? (spent / limit) : 0.0;
    final progress = min(1.0, ratio);
    final isExceeded = status == BudgetStatus.exceeded;
    final isWarning = status == BudgetStatus.warning;

    final barColor = isExceeded
        ? AppColors.expense
        : isWarning
            ? AppColors.warning
            : category.color;

    return CustomCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(14),
      onTap: onEdit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(category.icon, color: category.color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      limit > 0
                          ? isExceeded
                              ? 'Exceeded by ${CurrencyFormatter.format(spent - limit, symbol: currencySymbol)}'
                              : '${CurrencyFormatter.format(limit - spent, symbol: currencySymbol)} remaining'
                          : 'No budget set',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isExceeded
                            ? AppColors.expense
                            : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.format(spent, symbol: currencySymbol),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (limit > 0)
                    Text(
                      'of ${CurrencyFormatter.format(limit, symbol: currencySymbol)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                ],
              ),
            ],
          ),
          if (limit > 0) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 6,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(barColor),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
