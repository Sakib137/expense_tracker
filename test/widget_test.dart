import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/models/transaction_item.dart';
import 'package:expense_tracker/models/category_item.dart';
import 'package:expense_tracker/models/budget_item.dart';
import 'package:expense_tracker/models/user_settings.dart';
import 'package:expense_tracker/utils/currency_formatter.dart';
import 'package:expense_tracker/state/app_state.dart';
import 'package:expense_tracker/state/app_state_provider.dart';
import 'package:expense_tracker/screens/splash_screen.dart';
import 'package:expense_tracker/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Models & Logic Unit Tests', () {
    test('TransactionItem JSON serialization and getters', () {
      final now = DateTime.now();
      final item = TransactionItem(
        title: 'Whole Foods Groceries',
        amount: 85.50,
        date: now,
        categoryId: 'groceries',
        type: TransactionType.expense,
        paymentMethod: PaymentMethod.creditCard,
        notes: 'Organic fruits',
      );

      expect(item.isExpense, isTrue);
      expect(item.isIncome, isFalse);

      final json = item.toJson();
      final restored = TransactionItem.fromJson(json);

      expect(restored.title, 'Whole Foods Groceries');
      expect(restored.amount, 85.50);
      expect(restored.categoryId, 'groceries');
      expect(restored.type, TransactionType.expense);
      expect(restored.paymentMethod, PaymentMethod.creditCard);
      expect(restored.notes, 'Organic fruits');
    });

    test('BudgetsConfig status calculations', () {
      expect(
        BudgetsConfig.calculateStatus(spent: 50.0, limit: 100.0),
        BudgetStatus.normal,
      );
      expect(
        BudgetsConfig.calculateStatus(spent: 85.0, limit: 100.0),
        BudgetStatus.warning,
      );
      expect(
        BudgetsConfig.calculateStatus(spent: 105.0, limit: 100.0),
        BudgetStatus.exceeded,
      );
    });

    test('CurrencyFormatter formatting', () {
      expect(CurrencyFormatter.format(1234.56, symbol: '\$'), '\$1,234.56');
      expect(CurrencyFormatter.formatCompact(1500000, symbol: '\$'), '\$1.5M');
      expect(CurrencyFormatter.formatCompact(2500, symbol: '\$'), '\$2.5K');
    });

    test('Resilient JSON parsing on empty/corrupted data', () {
      final tx = TransactionItem.fromJson({});
      expect(tx.title, 'Untitled Transaction');
      expect(tx.amount, 0.0);
      expect(tx.categoryId, 'expense_other');
      expect(tx.paymentMethod, PaymentMethod.cash);

      final cat = CategoryItem.fromJson({});
      expect(cat.id, 'custom_unknown');
      expect(cat.name, 'Custom Category');

      final budget = BudgetsConfig.fromJson({});
      expect(budget.overallMonthlyBudget, 2500.0);
      expect(budget.categoryBudgets, isEmpty);
    });

    test('UserSettings copyWith and JSON roundtrip', () {
      const settings = UserSettings(
        userName: 'Alex',
        currencySymbol: '€',
        themeMode: ThemeMode.dark,
        profileImagePath: '/path/to/img.jpg',
      );

      final updated = settings.copyWith(userName: 'Jordan');
      expect(updated.userName, 'Jordan');
      expect(updated.currencySymbol, '€');
      expect(updated.themeMode, ThemeMode.dark);

      final json = updated.toJson();
      final restored = UserSettings.fromJson(json);
      expect(restored.userName, 'Jordan');
      expect(restored.currencySymbol, '€');
      expect(restored.themeMode, ThemeMode.dark);
    });
  });

  group('AppState Business Logic Tests', () {
    test('Period income and expense calculations', () async {
      final appState = AppState();
      await appState.loadData();

      final weekIncome = appState.getPeriodIncome(AnalyticsPeriod.thisWeek);
      final weekExpense = appState.getPeriodExpenses(AnalyticsPeriod.thisWeek);
      expect(weekIncome, isA<double>());
      expect(weekExpense, isA<double>());

      final monthIncome = appState.getPeriodIncome(AnalyticsPeriod.thisMonth);
      final monthExpense = appState.getPeriodExpenses(AnalyticsPeriod.thisMonth);
      expect(monthIncome, appState.thisMonthIncome);
      expect(monthExpense, appState.thisMonthExpenses);

      final allIncome = appState.getPeriodIncome(AnalyticsPeriod.allTime);
      final allExpense = appState.getPeriodExpenses(AnalyticsPeriod.allTime);
      expect(allIncome, appState.totalIncome);
      expect(allExpense, appState.totalExpenses);
    });

    test('Deleting category cleans up category budget mapping', () async {
      final appState = AppState();
      await appState.loadData();

      // Add custom category and budget
      const customCategory = CategoryItem(
        id: 'test_gym_sub',
        name: 'Gym Sub',
        iconKey: 'fitness_center',
        colorValue: 0xFF10B981,
        type: CategoryType.expense,
        isCustom: true,
      );
      await appState.addCategory(customCategory);
      await appState.updateCategoryBudget('test_gym_sub', 150.0);
      expect(appState.budgets.categoryBudgets['test_gym_sub'], 150.0);

      // Delete custom category
      await appState.deleteCategory('test_gym_sub');
      expect(appState.categories.any((c) => c.id == 'test_gym_sub'), isFalse);
      expect(appState.budgets.categoryBudgets.containsKey('test_gym_sub'), isFalse);
    });
    test('Initial data loads default categories and seed transactions', () async {
      final appState = AppState();
      await appState.loadData();

      expect(appState.categories.isNotEmpty, isTrue);
      expect(appState.allTransactions.isNotEmpty, isTrue);
      expect(appState.totalBalance, isNonZero);
    });

    test('Add, edit, delete, and undo delete transaction', () async {
      final appState = AppState();
      await appState.loadData();

      final initialCount = appState.allTransactions.length;
      final newTx = TransactionItem(
        title: 'Freelance Design',
        amount: 500.0,
        date: DateTime.now(),
        categoryId: 'freelance',
        type: TransactionType.income,
        paymentMethod: PaymentMethod.bankTransfer,
      );

      // Add transaction
      await appState.addTransaction(newTx);
      expect(appState.allTransactions.length, initialCount + 1);

      // Edit transaction
      final edited = newTx.copyWith(title: 'UniqueDesignJob');
      await appState.updateTransaction(edited);
      expect(appState.allTransactions.firstWhere((t) => t.id == newTx.id).title, 'UniqueDesignJob');

      // Delete transaction
      final deleted = await appState.deleteTransaction(newTx.id);
      expect(appState.allTransactions.length, initialCount);
      expect(deleted?.id, newTx.id);

      // Restore transaction
      await appState.restoreTransaction(deleted!);
      expect(appState.allTransactions.length, initialCount + 1);

      // Test search filter
      appState.setSearchQuery('UniqueDesignJob');
      expect(appState.filteredTransactions.length, 1);
      expect(appState.filteredTransactions.first.title, 'UniqueDesignJob');

      // Clear search
      appState.setSearchQuery('');
      expect(appState.filteredTransactions.length, initialCount + 1);
    });
  });

  group('Splash Screen & App Widget Smoke Tests', () {
    testWidgets('SplashScreen renders branding and handles tap to skip', (WidgetTester tester) async {
      final appState = AppState();
      await appState.loadData();

      await tester.pumpWidget(
        AppStateProvider(
          appState: appState,
          child: const MaterialApp(
            home: SplashScreen(
              displayDuration: Duration(seconds: 10),
            ),
          ),
        ),
      );

      // Verify branding texts render
      expect(find.text('Expense Tracker'), findsOneWidget);
      expect(find.text('Track • Save • Grow'), findsOneWidget);
      expect(find.text('Tap to skip'), findsOneWidget);

      // Tap to skip
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      // Should transition to MainScaffold
      expect(find.text('Total Balance'), findsOneWidget);
    });

    testWidgets('ExpenseTrackerApp builds and displays dashboard', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final appState = AppState();
      await appState.loadData();

      await tester.pumpWidget(
        AppStateProvider(
          appState: appState,
          child: const ExpenseTrackerApp(),
        ),
      );
      // Wait for splash transition
      await tester.pumpAndSettle();

      // Verify dashboard header and balance card
      expect(find.text('Hello, Alex'), findsOneWidget);
      expect(find.text('Total Balance'), findsOneWidget);
      expect(find.text('Recent Transactions'), findsOneWidget);

      // Verify bottom navigation bar destinations
      final navBar = find.byType(NavigationBar);
      expect(navBar, findsOneWidget);
      expect(find.descendant(of: navBar, matching: find.text('Dashboard')), findsOneWidget);
      expect(find.descendant(of: navBar, matching: find.text('History')), findsOneWidget);
      expect(find.descendant(of: navBar, matching: find.text('Analytics')), findsOneWidget);
      expect(find.descendant(of: navBar, matching: find.text('Budgets')), findsOneWidget);
      expect(find.descendant(of: navBar, matching: find.text('Settings')), findsOneWidget);

      // Navigate to History tab
      await tester.tap(find.descendant(of: navBar, matching: find.text('History')));
      await tester.pumpAndSettle();
      expect(find.text('Transactions'), findsOneWidget);

      // Navigate to Analytics tab
      await tester.tap(find.descendant(of: navBar, matching: find.text('Analytics')));
      await tester.pumpAndSettle();
      expect(find.text('Financial Analytics'), findsOneWidget);

      // Navigate to Budgets tab
      await tester.tap(find.descendant(of: navBar, matching: find.text('Budgets')));
      await tester.pumpAndSettle();
      expect(find.text('Budget Management'), findsOneWidget);

      // Navigate to Settings tab
      await tester.tap(find.descendant(of: navBar, matching: find.text('Settings')));
      await tester.pumpAndSettle();
      expect(find.text('Settings & Categories'), findsOneWidget);
      expect(find.text('About App'), findsOneWidget);
    });
  });
}
