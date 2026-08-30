import 'package:flutter/material.dart';
import 'package:expense_tracker/models/transaction_item.dart';
import 'package:expense_tracker/models/category_item.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/utils/currency_formatter.dart';
import 'package:expense_tracker/utils/date_helpers.dart';

class TransactionDetailDialog extends StatelessWidget {
  final TransactionItem transaction;
  final CategoryItem category;
  final String currencySymbol;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TransactionDetailDialog({
    super.key,
    required this.transaction,
    required this.category,
    required this.currencySymbol,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpense = transaction.isExpense;
    final amountColor = isExpense ? AppColors.expense : AppColors.income;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Icon & Category
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  category.icon,
                  color: category.color,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              transaction.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),

            // Category Name
            Text(
              category.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Formatted Amount
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: amountColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${isExpense ? '-' : '+'}${CurrencyFormatter.format(transaction.amount, symbol: currencySymbol)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: amountColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Metadata rows
            _InfoRow(
              icon: Icons.calendar_today_rounded,
              label: 'Date',
              value: DateHelpers.formatFull(transaction.date),
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.payment_rounded,
              label: 'Payment Method',
              value: transaction.paymentMethod.displayName,
            ),
            if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.notes_rounded,
                label: 'Notes',
                value: transaction.notes!,
              ),
            ],
            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onDelete();
                    },
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.expense, size: 18),
                    label: const Text('Delete', style: TextStyle(color: AppColors.expense)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.expense),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onEdit();
                    },
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: const Text('Edit'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
