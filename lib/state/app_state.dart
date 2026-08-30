import 'dart:math';
import 'package:flutter/material.dart';
import 'package:expense_tracker/models/transaction_item.dart';
import 'package:expense_tracker/models/category_item.dart';
import 'package:expense_tracker/models/budget_item.dart';
import 'package:expense_tracker/models/user_settings.dart';
import 'package:expense_tracker/models/financial_insight.dart';
import 'package:expense_tracker/repositories/expense_repository.dart';
import 'package:expense_tracker/utils/date_helpers.dart';
import 'package:expense_tracker/utils/currency_formatter.dart';

enum DateRangeFilter {
  all,
  today,
  thisWeek,
  thisMonth,
  custom,
}

enum SortOption {
  dateDesc, // Newest first
  dateAsc,  // Oldest first
  amountDesc, // Highest first
  amountAsc,  // Lowest first
  titleAsc,   // Alphabetical
}

enum AnalyticsPeriod {
  thisWeek,
  thisMonth,
  thisYear,
  allTime,
}

class CategorySpending {
  final CategoryItem category;
  final double totalAmount;
  final double percentage;

  const CategorySpending({
    required this.category,
    required this.totalAmount,
    required this.percentage,
  });
}

class MonthComparisonItem {
  final String monthLabel;
  final double income;
  final double expense;

  const MonthComparisonItem({
    required this.monthLabel,
    required this.income,
    required this.expense,
  });
}

class TrendPoint {
  final String label;
  final double amount;
  final DateTime date;

  const TrendPoint({
    required this.label,
    required this.amount,
    required this.date,
  });
}

class AppState extends ChangeNotifier {
  final ExpenseRepository _repository;

  List<TransactionItem> _transactions = [];
  List<CategoryItem> _categories = [];
  BudgetsConfig _budgets = BudgetsConfig.defaultBudgets();
  UserSettings _settings = const UserSettings();
  bool _isLoading = true;

  // Filter & Search states
  String _searchQuery = '';
  TransactionType? _selectedTypeFilter;
  DateRangeFilter _selectedDateFilter = DateRangeFilter.all;
  DateTimeRange? _customDateRange;
  String? _selectedCategoryFilter;
  SortOption _selectedSortOption = SortOption.dateDesc;
  AnalyticsPeriod _selectedAnalyticsPeriod = AnalyticsPeriod.thisMonth;

  AppState({ExpenseRepository? repository})
      : _repository = repository ?? ExpenseRepository() {
    loadData();
  }

  // Getters
  bool get isLoading => _isLoading;
  List<TransactionItem> get allTransactions => List.unmodifiable(_transactions);
  List<CategoryItem> get categories => List.unmodifiable(_categories);
  BudgetsConfig get budgets => _budgets;
  UserSettings get settings => _settings;
  String get currencySymbol => _settings.currencySymbol;
  ThemeMode get themeMode => _settings.themeMode;

  String get searchQuery => _searchQuery;
  TransactionType? get selectedTypeFilter => _selectedTypeFilter;
  DateRangeFilter get selectedDateFilter => _selectedDateFilter;
  DateTimeRange? get customDateRange => _customDateRange;
  String? get selectedCategoryFilter => _selectedCategoryFilter;
  SortOption get selectedSortOption => _selectedSortOption;
  AnalyticsPeriod get selectedAnalyticsPeriod => _selectedAnalyticsPeriod;

  // Load initial data
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    _categories = await _repository.getCategories();
    _transactions = await _repository.getTransactions();
    _budgets = await _repository.getBudgets();
    _settings = await _repository.getSettings();

    _isLoading = false;
    notifyListeners();
  }

  // Filtered Transactions
  List<TransactionItem> get filteredTransactions {
    return _transactions.where((item) {
      // Search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final titleMatches = item.title.toLowerCase().contains(query);
        final notesMatches = item.notes?.toLowerCase().contains(query) ?? false;
        final category = getCategoryById(item.categoryId);
        final categoryMatches = category.name.toLowerCase().contains(query);
        if (!titleMatches && !notesMatches && !categoryMatches) {
          return false;
        }
      }

      // Type filter
      if (_selectedTypeFilter != null && item.type != _selectedTypeFilter) {
        return false;
      }

      // Category filter
      if (_selectedCategoryFilter != null && item.categoryId != _selectedCategoryFilter) {
        return false;
      }

      // Date filter
      switch (_selectedDateFilter) {
        case DateRangeFilter.all:
          break;
        case DateRangeFilter.today:
          if (!DateHelpers.isSameDay(item.date, DateTime.now())) return false;
          break;
        case DateRangeFilter.thisWeek:
          if (!DateHelpers.isThisWeek(item.date)) return false;
          break;
        case DateRangeFilter.thisMonth:
          if (!DateHelpers.isThisMonth(item.date)) return false;
          break;
        case DateRangeFilter.custom:
          if (_customDateRange != null) {
            final start = DateTime(
              _customDateRange!.start.year,
              _customDateRange!.start.month,
              _customDateRange!.start.day,
            );
            final end = DateTime(
              _customDateRange!.end.year,
              _customDateRange!.end.month,
              _customDateRange!.end.day,
              23,
              59,
              59,
            );
            if (item.date.isBefore(start) || item.date.isAfter(end)) return false;
          }
          break;
      }

      return true;
    }).toList()
      ..sort((a, b) {
        switch (_selectedSortOption) {
          case SortOption.dateDesc:
            return b.date.compareTo(a.date);
          case SortOption.dateAsc:
            return a.date.compareTo(b.date);
          case SortOption.amountDesc:
            return b.amount.compareTo(a.amount);
          case SortOption.amountAsc:
            return a.amount.compareTo(b.amount);
          case SortOption.titleAsc:
            return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        }
      });
  }

  // Core Financial Summaries
  double get totalIncome {
    return _transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpenses {
    return _transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalBalance => totalIncome - totalExpenses;

  double get thisMonthIncome {
    return _transactions
        .where((t) => t.type == TransactionType.income && DateHelpers.isThisMonth(t.date))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get thisMonthExpenses {
    return _transactions
        .where((t) => t.type == TransactionType.expense && DateHelpers.isThisMonth(t.date))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get thisMonthBalance => thisMonthIncome - thisMonthExpenses;

  double get savingsRate {
    if (thisMonthIncome <= 0) return 0.0;
    final saved = thisMonthIncome - thisMonthExpenses;
    return max(0.0, saved / thisMonthIncome);
  }

  List<TransactionItem> get recentTransactions {
    final list = List<TransactionItem>.from(_transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    return list.take(5).toList();
  }

  CategoryItem getCategoryById(String id) {
    return _categories.firstWhere(
      (c) => c.id == id,
      orElse: () => CategoryItem(
        id: id,
        name: 'Uncategorized',
        iconKey: 'category',
        colorValue: 0xFF64748B,
        type: CategoryType.expense,
      ),
    );
  }

  List<CategoryItem> get expenseCategories =>
      _categories.where((c) => c.type == CategoryType.expense).toList();

  List<CategoryItem> get incomeCategories =>
      _categories.where((c) => c.type == CategoryType.income).toList();

  // Category Distribution for Analytics
  List<CategorySpending> getCategoryDistribution(AnalyticsPeriod period) {
    final periodTransactions = _getTransactionsForPeriod(period)
        .where((t) => t.type == TransactionType.expense)
        .toList();

    final totalSpent = periodTransactions.fold(0.0, (sum, t) => sum + t.amount);
    if (totalSpent <= 0) return [];

    final Map<String, double> categorySums = {};
    for (final t in periodTransactions) {
      categorySums[t.categoryId] = (categorySums[t.categoryId] ?? 0.0) + t.amount;
    }

    final distribution = categorySums.entries.map((entry) {
      final category = getCategoryById(entry.key);
      final amount = entry.value;
      final percentage = amount / totalSpent;
      return CategorySpending(
        category: category,
        totalAmount: amount,
        percentage: percentage,
      );
    }).toList()
      ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    return distribution;
  }

  // Monthly Comparison (Income vs Expense) for the last 6 months
  List<MonthComparisonItem> getMonthlyComparison() {
    final now = DateTime.now();
    final List<MonthComparisonItem> items = [];

    for (int i = 5; i >= 0; i--) {
      final targetDate = DateTime(now.year, now.month - i, 1);
      final monthTransactions = _transactions.where(
        (t) => t.date.year == targetDate.year && t.date.month == targetDate.month,
      );

      final income = monthTransactions
          .where((t) => t.type == TransactionType.income)
          .fold(0.0, (sum, t) => sum + t.amount);

      final expense = monthTransactions
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (sum, t) => sum + t.amount);

      final label = DateHelpers.formatShort(targetDate).split(' ').first; // e.g. "Aug"
      items.add(MonthComparisonItem(
        monthLabel: label,
        income: income,
        expense: expense,
      ));
    }

    return items;
  }

  // Spending Trend Points for Line Chart
  List<TrendPoint> getSpendingTrend(AnalyticsPeriod period) {
    final now = DateTime.now();
    final List<TrendPoint> points = [];

    if (period == AnalyticsPeriod.thisWeek) {
      // 7 days of the current week (Mon-Sun)
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      for (int i = 0; i < 7; i++) {
        final day = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day + i);
        final dayExpenses = _transactions
            .where((t) => t.type == TransactionType.expense && DateHelpers.isSameDay(t.date, day))
            .fold(0.0, (sum, t) => sum + t.amount);
        final label = ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i];
        points.add(TrendPoint(label: label, amount: dayExpenses, date: day));
      }
    } else if (period == AnalyticsPeriod.thisMonth) {
      // 4 weeks of the month
      final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
      for (int week = 1; week <= 4; week++) {
        final startDay = (week - 1) * 7 + 1;
        final endDay = week == 4 ? daysInMonth : week * 7;
        final weekExpenses = _transactions.where((t) {
          return t.type == TransactionType.expense &&
              t.date.year == now.year &&
              t.date.month == now.month &&
              t.date.day >= startDay &&
              t.date.day <= endDay;
        }).fold(0.0, (sum, t) => sum + t.amount);
        points.add(TrendPoint(
          label: 'W$week',
          amount: weekExpenses,
          date: DateTime(now.year, now.month, startDay),
        ));
      }
    } else {
      // Monthly points for this year or all time (last 6 months)
      final comparison = getMonthlyComparison();
      for (final item in comparison) {
        points.add(TrendPoint(
          label: item.monthLabel,
          amount: item.expense,
          date: now,
        ));
      }
    }

    return points;
  }

  // Budget Calculations
  double get totalBudgetSpentThisMonth => thisMonthExpenses;

  double get overallBudgetLimit => _budgets.overallMonthlyBudget;

  double get overallBudgetPercentage {
    if (overallBudgetLimit <= 0) return 0.0;
    return totalBudgetSpentThisMonth / overallBudgetLimit;
  }

  double get overallBudgetRemaining =>
      max(0.0, overallBudgetLimit - totalBudgetSpentThisMonth);

  BudgetStatus get overallBudgetStatus => BudgetsConfig.calculateStatus(
        spent: totalBudgetSpentThisMonth,
        limit: overallBudgetLimit,
      );

  double getCategorySpentThisMonth(String categoryId) {
    return _transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            t.categoryId == categoryId &&
            DateHelpers.isThisMonth(t.date))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  BudgetStatus getCategoryBudgetStatus(String categoryId) {
    final limit = _budgets.categoryBudgets[categoryId] ?? 0.0;
    final spent = getCategorySpentThisMonth(categoryId);
    return BudgetsConfig.calculateStatus(spent: spent, limit: limit);
  }

  List<CategoryBudgetAlert> get budgetAlerts {
    final List<CategoryBudgetAlert> alerts = [];

    // Overall budget alert
    if (overallBudgetStatus != BudgetStatus.normal) {
      alerts.add(CategoryBudgetAlert(
        categoryName: 'Overall Monthly Budget',
        spent: totalBudgetSpentThisMonth,
        limit: overallBudgetLimit,
        status: overallBudgetStatus,
        category: null,
      ));
    }

    // Category specific alerts
    for (final entry in _budgets.categoryBudgets.entries) {
      final categoryId = entry.key;
      final limit = entry.value;
      if (limit <= 0) continue;

      final spent = getCategorySpentThisMonth(categoryId);
      final status = BudgetsConfig.calculateStatus(spent: spent, limit: limit);
      if (status != BudgetStatus.normal) {
        final category = getCategoryById(categoryId);
        alerts.add(CategoryBudgetAlert(
          categoryName: category.name,
          spent: spent,
          limit: limit,
          status: status,
          category: category,
        ));
      }
    }

    return alerts;
  }

  // Smart Automated Financial Insights
  List<FinancialInsight> get financialInsights {
    final List<FinancialInsight> insights = [];

    // 1. Savings Rate Insight
    final rate = savingsRate;
    if (rate >= 0.3) {
      insights.add(FinancialInsight(
        title: 'Excellent Savings Rate',
        description: 'You have saved ${CurrencyFormatter.formatPercent(rate)} of your income this month. Keep up this stellar momentum!',
        icon: Icons.savings_rounded,
        type: InsightType.positive,
        metricValue: CurrencyFormatter.formatPercent(rate),
      ));
    } else if (rate > 0) {
      insights.add(FinancialInsight(
        title: 'Positive Net Flow',
        description: 'Your savings rate is ${CurrencyFormatter.formatPercent(rate)}. Consider setting category budget caps to increase monthly savings.',
        icon: Icons.trending_up_rounded,
        type: InsightType.info,
        metricValue: CurrencyFormatter.formatPercent(rate),
      ));
    } else {
      insights.add(const FinancialInsight(
        title: 'Expenses Exceed Income',
        description: 'Your expenses this month have outpaced income. Review your top discretionary categories below to rebalance.',
        icon: Icons.warning_amber_rounded,
        type: InsightType.warning,
      ));
    }

    // 2. Top Category Spending
    final distribution = getCategoryDistribution(AnalyticsPeriod.thisMonth);
    if (distribution.isNotEmpty) {
      final top = distribution.first;
      insights.add(FinancialInsight(
        title: 'Top Expense: ${top.category.name}',
        description: '${CurrencyFormatter.formatPercent(top.percentage)} of your total spend went to ${top.category.name} (${CurrencyFormatter.format(top.totalAmount, symbol: currencySymbol)}).',
        icon: top.category.icon,
        type: top.percentage > 0.4 ? InsightType.warning : InsightType.info,
        metricValue: CurrencyFormatter.format(top.totalAmount, symbol: currencySymbol),
      ));
    }

    // 3. Average Daily Spending Velocity
    final now = DateTime.now();
    final dayOfMonth = now.day;
    if (dayOfMonth > 0 && thisMonthExpenses > 0) {
      final dailyAvg = thisMonthExpenses / dayOfMonth;
      insights.add(FinancialInsight(
        title: 'Daily Spending Velocity',
        description: 'You are spending an average of ${CurrencyFormatter.format(dailyAvg, symbol: currencySymbol)} per day this month.',
        icon: Icons.speed_rounded,
        type: InsightType.tip,
        metricValue: '${CurrencyFormatter.format(dailyAvg, symbol: currencySymbol)}/day',
      ));
    }

    return insights;
  }

  // CRUD Actions
  Future<void> addTransaction(TransactionItem transaction) async {
    _transactions.insert(0, transaction);
    notifyListeners();
    await _repository.saveTransactions(_transactions);
  }

  Future<void> updateTransaction(TransactionItem transaction) async {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
      notifyListeners();
      await _repository.saveTransactions(_transactions);
    }
  }

  Future<TransactionItem?> deleteTransaction(String id) async {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index != -1) {
      final deleted = _transactions.removeAt(index);
      notifyListeners();
      await _repository.saveTransactions(_transactions);
      return deleted;
    }
    return null;
  }

  Future<void> restoreTransaction(TransactionItem transaction, [int? index]) async {
    if (index != null && index >= 0 && index <= _transactions.length) {
      _transactions.insert(index, transaction);
    } else {
      _transactions.insert(0, transaction);
    }
    notifyListeners();
    await _repository.saveTransactions(_transactions);
  }

  Future<void> addCategory(CategoryItem category) async {
    _categories.add(category);
    notifyListeners();
    await _repository.saveCategories(_categories);
  }

  Future<void> updateCategory(CategoryItem category) async {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
      notifyListeners();
      await _repository.saveCategories(_categories);
    }
  }

  Future<void> deleteCategory(String id) async {
    _categories.removeWhere((c) => c.id == id);
    notifyListeners();
    await _repository.saveCategories(_categories);
  }

  Future<void> updateOverallBudget(double amount) async {
    _budgets = _budgets.copyWith(overallMonthlyBudget: amount);
    notifyListeners();
    await _repository.saveBudgets(_budgets);
  }

  Future<void> updateCategoryBudget(String categoryId, double limit) async {
    final updated = Map<String, double>.from(_budgets.categoryBudgets);
    if (limit <= 0) {
      updated.remove(categoryId);
    } else {
      updated[categoryId] = limit;
    }
    _budgets = _budgets.copyWith(categoryBudgets: updated);
    notifyListeners();
    await _repository.saveBudgets(_budgets);
  }

  Future<void> updateUserSettings({
    String? currencySymbol,
    ThemeMode? themeMode,
    String? userName,
    String? profileImagePath,
    bool clearProfileImage = false,
  }) async {
    _settings = _settings.copyWith(
      currencySymbol: currencySymbol,
      themeMode: themeMode,
      userName: userName,
      profileImagePath: profileImagePath,
      clearProfileImage: clearProfileImage,
    );
    notifyListeners();
    await _repository.saveSettings(_settings);
  }

  Future<void> resetAllData() async {
    await _repository.resetAll();
    await loadData();
  }

  // Filter Modifiers
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setTypeFilter(TransactionType? type) {
    _selectedTypeFilter = type;
    notifyListeners();
  }

  void setDateFilter(DateRangeFilter filter, {DateTimeRange? customRange}) {
    _selectedDateFilter = filter;
    _customDateRange = customRange;
    notifyListeners();
  }

  void setCategoryFilter(String? categoryId) {
    _selectedCategoryFilter = categoryId;
    notifyListeners();
  }

  void setSortOption(SortOption option) {
    _selectedSortOption = option;
    notifyListeners();
  }

  void setAnalyticsPeriod(AnalyticsPeriod period) {
    _selectedAnalyticsPeriod = period;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedTypeFilter = null;
    _selectedDateFilter = DateRangeFilter.all;
    _customDateRange = null;
    _selectedCategoryFilter = null;
    _selectedSortOption = SortOption.dateDesc;
    notifyListeners();
  }

  // Helper
  List<TransactionItem> _getTransactionsForPeriod(AnalyticsPeriod period) {
    switch (period) {
      case AnalyticsPeriod.thisWeek:
        return _transactions.where((t) => DateHelpers.isThisWeek(t.date)).toList();
      case AnalyticsPeriod.thisMonth:
        return _transactions.where((t) => DateHelpers.isThisMonth(t.date)).toList();
      case AnalyticsPeriod.thisYear:
        return _transactions.where((t) => DateHelpers.isThisYear(t.date)).toList();
      case AnalyticsPeriod.allTime:
        return _transactions;
    }
  }
}

class CategoryBudgetAlert {
  final String categoryName;
  final double spent;
  final double limit;
  final BudgetStatus status;
  final CategoryItem? category;

  const CategoryBudgetAlert({
    required this.categoryName,
    required this.spent,
    required this.limit,
    required this.status,
    this.category,
  });
}
