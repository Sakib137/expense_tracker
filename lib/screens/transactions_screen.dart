import 'package:flutter/material.dart';
import 'package:expense_tracker/state/app_state.dart';
import 'package:expense_tracker/state/app_state_provider.dart';
import 'package:expense_tracker/models/transaction_item.dart';
import 'package:expense_tracker/models/category_item.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/utils/currency_formatter.dart';
import 'package:expense_tracker/utils/date_helpers.dart';
import 'package:expense_tracker/widgets/transactions/transaction_tile.dart';
import 'package:expense_tracker/widgets/transactions/transaction_filters.dart';
import 'package:expense_tracker/widgets/transactions/search_bar_widget.dart';
import 'package:expense_tracker/widgets/transactions/add_edit_transaction_sheet.dart';
import 'package:expense_tracker/widgets/transactions/transaction_detail_dialog.dart';
import 'package:expense_tracker/widgets/common/empty_state_view.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  void _openAddTransactionSheet(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddEditTransactionSheet(
        categories: appState.categories,
        currencySymbol: appState.currencySymbol,
        initialType: appState.selectedTypeFilter ?? TransactionType.expense,
        onSave: (transaction) => appState.addTransaction(transaction),
      ),
    );
  }

  void _openEditTransactionSheet(
    BuildContext context,
    AppState appState,
    TransactionItem transaction,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddEditTransactionSheet(
        categories: appState.categories,
        currencySymbol: appState.currencySymbol,
        existingTransaction: transaction,
        onSave: (updated) => appState.updateTransaction(updated),
      ),
    );
  }

  void _showTransactionDetails(
    BuildContext context,
    AppState appState,
    TransactionItem transaction,
  ) {
    final category = appState.getCategoryById(transaction.categoryId);
    showDialog(
      context: context,
      builder: (ctx) => TransactionDetailDialog(
        transaction: transaction,
        category: category,
        currencySymbol: appState.currencySymbol,
        onEdit: () => _openEditTransactionSheet(context, appState, transaction),
        onDelete: () => _deleteTransactionWithUndo(context, appState, transaction),
      ),
    );
  }

  void _deleteTransactionWithUndo(
    BuildContext context,
    AppState appState,
    TransactionItem transaction,
  ) async {
    final deleted = await appState.deleteTransaction(transaction.id);
    if (deleted != null && context.mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted "${transaction.title}"'),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Undo',
            textColor: AppColors.incomeLight,
            onPressed: () => appState.restoreTransaction(deleted),
          ),
        ),
      );
    }
  }

  void _openSortSheet(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'Sort Transactions By',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                _SortListTile(
                  title: 'Date: Newest First',
                  isSelected: appState.selectedSortOption == SortOption.dateDesc,
                  onTap: () {
                    appState.setSortOption(SortOption.dateDesc);
                    Navigator.pop(ctx);
                  },
                ),
                _SortListTile(
                  title: 'Date: Oldest First',
                  isSelected: appState.selectedSortOption == SortOption.dateAsc,
                  onTap: () {
                    appState.setSortOption(SortOption.dateAsc);
                    Navigator.pop(ctx);
                  },
                ),
                _SortListTile(
                  title: 'Amount: Highest First',
                  isSelected: appState.selectedSortOption == SortOption.amountDesc,
                  onTap: () {
                    appState.setSortOption(SortOption.amountDesc);
                    Navigator.pop(ctx);
                  },
                ),
                _SortListTile(
                  title: 'Amount: Lowest First',
                  isSelected: appState.selectedSortOption == SortOption.amountAsc,
                  onTap: () {
                    appState.setSortOption(SortOption.amountAsc);
                    Navigator.pop(ctx);
                  },
                ),
                _SortListTile(
                  title: 'Title: Alphabetical (A-Z)',
                  isSelected: appState.selectedSortOption == SortOption.titleAsc,
                  onTap: () {
                    appState.setSortOption(SortOption.titleAsc);
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openCategoryFilterSheet(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.85,
          minChildSize: 0.4,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter by Category',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      if (appState.selectedCategoryFilter != null)
                        TextButton(
                          onPressed: () {
                            appState.setCategoryFilter(null);
                            Navigator.pop(ctx);
                          },
                          child: const Text('Clear Filter'),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: appState.categories.length,
                    itemBuilder: (context, index) {
                      final cat = appState.categories[index];
                      final isSelected = appState.selectedCategoryFilter == cat.id;

                      return ListTile(
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: cat.color.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(cat.icon, color: cat.color, size: 20),
                        ),
                        title: Text(
                          cat.name,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(cat.type == CategoryType.income ? 'Income' : 'Expense'),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                            : null,
                        onTap: () {
                          appState.setCategoryFilter(isSelected ? null : cat.id);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _selectCustomDateRange(BuildContext context, AppState appState) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      initialDateRange: appState.customDateRange ??
          DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now),
    );

    if (picked != null) {
      appState.setDateFilter(DateRangeFilter.custom, customRange: picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final transactions = appState.filteredTransactions;
    final theme = Theme.of(context);

    // Calculate totals for currently filtered transactions
    final filteredIncome = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    final filteredExpense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _openAddTransactionSheet(context, appState),
            tooltip: 'Add Transaction',
          ),
        ],
      ),
      body: Column(
        children: [
          // Real-time Search Bar
          SearchBarWidget(
            initialValue: appState.searchQuery,
            onChanged: (q) => appState.setSearchQuery(q),
            onClear: () => appState.setSearchQuery(''),
          ),

          // Filters Bar
          TransactionFilters(
            selectedType: appState.selectedTypeFilter,
            selectedDateFilter: appState.selectedDateFilter,
            selectedCategoryId: appState.selectedCategoryFilter,
            selectedSortOption: appState.selectedSortOption,
            onTypeChanged: (t) => appState.setTypeFilter(t),
            onDateFilterChanged: (df) => appState.setDateFilter(df),
            onSelectCustomDateRange: () => _selectCustomDateRange(context, appState),
            onOpenSortSheet: () => _openSortSheet(context, appState),
            onOpenCategoryFilterSheet: () => _openCategoryFilterSheet(context, appState),
          ),

          // Filter Summary Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${transactions.length} ${transactions.length == 1 ? "record" : "records"}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                Row(
                  children: [
                    if (filteredIncome > 0) ...[
                      Text(
                        '+${CurrencyFormatter.format(filteredIncome, symbol: appState.currencySymbol)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.income,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (filteredExpense > 0)
                      Text(
                        '-${CurrencyFormatter.format(filteredExpense, symbol: appState.currencySymbol)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.expense,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Transactions List or Empty State
          Expanded(
            child: transactions.isEmpty
                ? EmptyStateView(
                    icon: Icons.search_off_rounded,
                    title: 'No Transactions Found',
                    description: 'Try adjusting your search query, dates, or active filters.',
                    actionText: 'Clear Filters',
                    onAction: () => appState.clearFilters(),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 90),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      final category = appState.getCategoryById(transaction.categoryId);

                      // Date Header grouping
                      bool showDateHeader = false;
                      if (index == 0) {
                        showDateHeader = true;
                      } else {
                        final prevTransaction = transactions[index - 1];
                        showDateHeader = !DateHelpers.isSameDay(
                          transaction.date,
                          prevTransaction.date,
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showDateHeader)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
                              child: Text(
                                DateHelpers.formatRelative(transaction.date),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          TransactionTile(
                            transaction: transaction,
                            category: category,
                            currencySymbol: appState.currencySymbol,
                            onTap: () => _showTransactionDetails(context, appState, transaction),
                            onDismissed: (dir) => _deleteTransactionWithUndo(context, appState, transaction),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SortListTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortListTile({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? AppColors.primary : null,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_rounded, color: AppColors.primary)
          : null,
      onTap: onTap,
    );
  }
}
