import 'package:flutter/material.dart';
import 'package:expense_tracker/state/app_state.dart';
import 'package:expense_tracker/state/app_state_provider.dart';
import 'package:expense_tracker/models/category_item.dart';
import 'package:expense_tracker/widgets/budgets/overall_budget_card.dart';
import 'package:expense_tracker/widgets/budgets/category_budget_tile.dart';
import 'package:expense_tracker/widgets/budgets/set_budget_sheet.dart';
import 'package:expense_tracker/widgets/common/section_header.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  void _openSetOverallBudget(BuildContext context, AppState appState) {
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

  void _openSetCategoryBudget(BuildContext context, AppState appState, CategoryItem category) {
    final currentLimit = appState.budgets.categoryBudgets[category.id] ?? 0.0;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SetBudgetSheet(
        title: '${category.name} Budget',
        currentLimit: currentLimit,
        currencySymbol: appState.currencySymbol,
        category: category,
        onSave: (newLimit) => appState.updateCategoryBudget(category.id, newLimit),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final expenseCategories = appState.expenseCategories;
    final currencySymbol = appState.currencySymbol;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Management'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 90),
        children: [
          // 1. Overall Monthly Budget Card
          OverallBudgetCard(
            spent: appState.totalBudgetSpentThisMonth,
            limit: appState.overallBudgetLimit,
            currencySymbol: currencySymbol,
            status: appState.overallBudgetStatus,
            onEditBudget: () => _openSetOverallBudget(context, appState),
          ),
          const SizedBox(height: 12),

          // 2. Category Budgets Header
          const SectionHeader(
            title: 'Category Budgets',
          ),

          // 3. Category Budgets List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: expenseCategories.length,
            itemBuilder: (context, index) {
              final category = expenseCategories[index];
              final limit = appState.budgets.categoryBudgets[category.id] ?? 0.0;
              final spent = appState.getCategorySpentThisMonth(category.id);
              final status = appState.getCategoryBudgetStatus(category.id);

              return CategoryBudgetTile(
                category: category,
                spent: spent,
                limit: limit,
                currencySymbol: currencySymbol,
                status: status,
                onEdit: () => _openSetCategoryBudget(context, appState, category),
              );
            },
          ),
        ],
      ),
    );
  }
}
