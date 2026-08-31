import 'package:flutter/material.dart';
import 'package:expense_tracker/state/app_state.dart';
import 'package:expense_tracker/state/app_state_provider.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/utils/currency_formatter.dart';
import 'package:expense_tracker/widgets/common/metric_card.dart';
import 'package:expense_tracker/widgets/analytics/category_pie_chart.dart';
import 'package:expense_tracker/widgets/analytics/income_expense_bar_chart.dart';
import 'package:expense_tracker/widgets/analytics/spending_trend_chart.dart';
import 'package:expense_tracker/widgets/analytics/insights_list_view.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final period = appState.selectedAnalyticsPeriod;
    final currencySymbol = appState.currencySymbol;

    final distribution = appState.getCategoryDistribution(period);
    final comparison = appState.getMonthlyComparison();
    final trendPoints = appState.getSpendingTrend(period);
    final insights = appState.financialInsights;

    // Calculate period specific summary dynamically
    final periodIncome = appState.getPeriodIncome(period);
    final periodExpense = appState.getPeriodExpenses(period);
    final netSavings = periodIncome - periodExpense;
    final savingsRate = periodIncome > 0 ? (netSavings / periodIncome) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Analytics'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 90),
        children: [
          // Period Switcher Segment
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _PeriodButton(
                    label: 'Week',
                    isSelected: period == AnalyticsPeriod.thisWeek,
                    onTap: () => appState.setAnalyticsPeriod(AnalyticsPeriod.thisWeek),
                  ),
                  _PeriodButton(
                    label: 'Month',
                    isSelected: period == AnalyticsPeriod.thisMonth,
                    onTap: () => appState.setAnalyticsPeriod(AnalyticsPeriod.thisMonth),
                  ),
                  _PeriodButton(
                    label: 'Year',
                    isSelected: period == AnalyticsPeriod.thisYear,
                    onTap: () => appState.setAnalyticsPeriod(AnalyticsPeriod.thisYear),
                  ),
                  _PeriodButton(
                    label: 'All',
                    isSelected: period == AnalyticsPeriod.allTime,
                    onTap: () => appState.setAnalyticsPeriod(AnalyticsPeriod.allTime),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 4 Grid Metric Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: MetricCard(
                    title: 'Total Income',
                    value: CurrencyFormatter.format(periodIncome, symbol: currencySymbol),
                    icon: Icons.arrow_downward_rounded,
                    iconColor: AppColors.income,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MetricCard(
                    title: 'Total Expense',
                    value: CurrencyFormatter.format(periodExpense, symbol: currencySymbol),
                    icon: Icons.arrow_upward_rounded,
                    iconColor: AppColors.expense,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: MetricCard(
                    title: 'Net Savings',
                    value: CurrencyFormatter.format(netSavings, symbol: currencySymbol),
                    icon: Icons.account_balance_wallet_rounded,
                    iconColor: netSavings >= 0 ? AppColors.income : AppColors.expense,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MetricCard(
                    title: 'Savings Rate',
                    value: CurrencyFormatter.formatPercent(savingsRate),
                    icon: Icons.savings_rounded,
                    iconColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 1. Expense Breakdown Donut Chart
          CategoryPieChart(
            distribution: distribution,
            currencySymbol: currencySymbol,
          ),
          const SizedBox(height: 12),

          // 2. Spending Trajectory Trend Line Chart
          SpendingTrendChart(
            trendPoints: trendPoints,
            currencySymbol: currencySymbol,
          ),
          const SizedBox(height: 12),

          // 3. Monthly Income vs Expense Comparison Bar Chart
          IncomeExpenseBarChart(
            comparisonData: comparison,
            currencySymbol: currencySymbol,
          ),
          const SizedBox(height: 12),

          // 4. Automated Financial Insights & Advice
          InsightsListView(insights: insights),
        ],
      ),
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }
}
