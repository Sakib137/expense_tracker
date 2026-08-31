import 'dart:async';
import 'package:flutter/material.dart';
import 'package:expense_tracker/state/app_state.dart';
import 'package:expense_tracker/state/app_state_provider.dart';
import 'package:expense_tracker/models/transaction_item.dart';
import 'package:expense_tracker/widgets/dashboard/balance_card.dart';
import 'package:expense_tracker/widgets/dashboard/quick_actions_row.dart';
import 'package:expense_tracker/widgets/dashboard/budget_alert_banner.dart';
import 'package:expense_tracker/widgets/transactions/transaction_tile.dart';
import 'package:expense_tracker/widgets/transactions/transaction_detail_dialog.dart';
import 'package:expense_tracker/widgets/transactions/add_edit_transaction_sheet.dart';
import 'package:expense_tracker/widgets/budgets/set_budget_sheet.dart';
import 'package:expense_tracker/widgets/common/section_header.dart';
import 'package:expense_tracker/widgets/common/empty_state_view.dart';
import 'package:expense_tracker/widgets/analytics/insights_list_view.dart';
import 'package:expense_tracker/widgets/common/user_avatar.dart';
import 'package:expense_tracker/theme/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback onNavigateToTransactions;
  final VoidCallback onNavigateToAnalytics;
  final VoidCallback onNavigateToBudgets;

  const DashboardScreen({
    super.key,
    required this.onNavigateToTransactions,
    required this.onNavigateToAnalytics,
    required this.onNavigateToBudgets,
  });

  void _openAddTransactionSheet(
    BuildContext context,
    AppState appState, {
    TransactionType type = TransactionType.expense,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddEditTransactionSheet(
        categories: appState.categories,
        currencySymbol: appState.currencySymbol,
        initialType: type,
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

  void _openSetBudgetSheet(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SetBudgetSheet(
        title: 'Monthly Total Budget',
        currentLimit: appState.overallBudgetLimit,
        currencySymbol: appState.currencySymbol,
        onSave: (newLimit) => appState.updateOverallBudget(newLimit),
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
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();

      final controller = messenger.showSnackBar(
        SnackBar(
          content: Text('Deleted "${transaction.title}"'),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          action: SnackBarAction(
            label: 'Undo',
            textColor: AppColors.incomeLight,
            onPressed: () => appState.restoreTransaction(deleted),
          ),
        ),
      );

      Timer(const Duration(seconds: 3), () {
        try {
          controller.close();
        } catch (_) {}
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final theme = Theme.of(context);
    final recentTransactions = appState.recentTransactions;
    final budgetAlerts = appState.budgetAlerts;
    final insights = appState.financialInsights;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            UserAvatar(
              size: 40,
              userName: appState.settings.userName,
              imagePath: appState.settings.profileImagePath,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${appState.settings.userName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Track your financial goals',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => appState.loadData(),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 90),
          children: [
            // Hero Balance Card
            BalanceCard(
              totalBalance: appState.totalBalance,
              totalIncome: appState.thisMonthIncome,
              totalExpenses: appState.thisMonthExpenses,
              savingsRate: appState.savingsRate,
              currencySymbol: appState.currencySymbol,
              onAddExpense: () => _openAddTransactionSheet(context, appState, type: TransactionType.expense),
              onAddIncome: () => _openAddTransactionSheet(context, appState, type: TransactionType.income),
            ),

            // Quick Actions
            QuickActionsRow(
              onAddExpense: () => _openAddTransactionSheet(context, appState, type: TransactionType.expense),
              onAddIncome: () => _openAddTransactionSheet(context, appState, type: TransactionType.income),
              onSetBudget: () => _openSetBudgetSheet(context, appState),
              onViewAnalytics: onNavigateToAnalytics,
            ),

            // Budget Alerts Banner
            if (budgetAlerts.isNotEmpty)
              BudgetAlertBanner(
                alerts: budgetAlerts,
                currencySymbol: appState.currencySymbol,
                onManageBudgets: onNavigateToBudgets,
              ),

            // Financial Insights Section
            if (insights.isNotEmpty)
              InsightsListView(insights: insights.take(2).toList()),

            // Recent Transactions Section Header
            SectionHeader(
              title: 'Recent Transactions',
              actionText: recentTransactions.isNotEmpty ? 'See All' : null,
              onAction: onNavigateToTransactions,
            ),

            // Recent Transactions List or Empty State
            if (recentTransactions.isEmpty)
              EmptyStateView(
                icon: Icons.receipt_long_rounded,
                title: 'No Transactions Yet',
                description: 'Add your first income or expense to start tracking.',
                actionText: 'Add Expense',
                onAction: () => _openAddTransactionSheet(context, appState, type: TransactionType.expense),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentTransactions.length,
                itemBuilder: (context, index) {
                  final transaction = recentTransactions[index];
                  final category = appState.getCategoryById(transaction.categoryId);

                  return TransactionTile(
                    transaction: transaction,
                    category: category,
                    currencySymbol: appState.currencySymbol,
                    onTap: () => _showTransactionDetails(context, appState, transaction),
                    onDismissed: (direction) => _deleteTransactionWithUndo(context, appState, transaction),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
