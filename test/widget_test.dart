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
      expect(CurrencyFormatter.format(50.0, symbol: '€'), '€50.00');
      expect(CurrencyFormatter.formatPercent(0.354), '35.4%');
    });

    test('UserSettings serialization with profileImagePath', () {
      const settings = UserSettings(
        userName: 'Taylor',
        currencySymbol: '€',
        themeMode: ThemeMode.dark,
        profileImagePath: '/path/to/profile.jpg',
      );

      final json = settings.toJson();
      final restored = UserSettings.fromJson(json);

      expect(restored.userName, 'Taylor');
      expect(restored.currencySymbol, '€');
      expect(restored.themeMode, ThemeMode.dark);
      expect(restored.profileImagePath, '/path/to/profile.jpg');

      final cleared = restored.copyWith(clearProfileImage: true);
      expect(cleared.profileImagePath, isNull);
    });

    test('CategoryItem default categories presence', () {
      final defaultCats = CategoryItem.defaultCategories;
      expect(defaultCats, isNotEmpty);
      expect(defaultCats.any((c) => c.name.contains('Food')), isTrue);
      expect(defaultCats.any((c) => c.name.contains('Salary')), isTrue);
    });
  });

  group('AppState State Management Tests', () {
    test('AppState initial load, add transaction, delete and calculations', () async {
      final appState = AppState();
      await appState.loadData();

      expect(appState.isLoading, isFalse);
      expect(appState.allTransactions, isNotEmpty);
      final initialCount = appState.allTransactions.length;

      // Add a test income transaction
      final newIncome = TransactionItem(
        title: 'Consulting Gig',
        amount: 1000.0,
        date: DateTime.now(),
        categoryId: 'business',
        type: TransactionType.income,
      );

      await appState.addTransaction(newIncome);
      expect(appState.allTransactions.length, initialCount + 1);
      expect(appState.allTransactions.first.title, 'Consulting Gig');

      // Test delete with undo
      final deleted = await appState.deleteTransaction(newIncome.id);
      expect(deleted, isNotNull);
      expect(appState.allTransactions.length, initialCount);

      // Restore transaction
      await appState.restoreTransaction(deleted!);
      expect(appState.allTransactions.length, initialCount + 1);

      // Test search filter
      appState.setSearchQuery('Consulting');
      expect(appState.filteredTransactions.length, 1);
      expect(appState.filteredTransactions.first.title, 'Consulting Gig');

      // Clear search
      appState.setSearchQuery('');
      expect(appState.filteredTransactions.length, initialCount + 1);
    });
  });

  group('App Widget Smoke Tests', () {
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
    });
  });
}
