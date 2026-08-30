import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/models/transaction_item.dart';
import 'package:expense_tracker/models/category_item.dart';
import 'package:expense_tracker/models/budget_item.dart';
import 'package:expense_tracker/models/user_settings.dart';

class StorageService {
  static const String _transactionsKey = 'expense_tracker_transactions';
  static const String _categoriesKey = 'expense_tracker_categories';
  static const String _budgetsKey = 'expense_tracker_budgets';
  static const String _settingsKey = 'expense_tracker_settings';
  static const String _hasInitializedKey = 'expense_tracker_initialized';

  Future<List<TransactionItem>> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final isInitialized = prefs.getBool(_hasInitializedKey) ?? false;

    if (!isInitialized) {
      final initialData = _generateInitialSeedData();
      await saveTransactions(initialData);
      await prefs.setBool(_hasInitializedKey, true);
      return initialData;
    }

    final rawJson = prefs.getString(_transactionsKey);
    if (rawJson == null || rawJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(rawJson);
      return decoded.map((item) => TransactionItem.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return _generateInitialSeedData();
    }
  }

  Future<void> saveTransactions(List<TransactionItem> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(transactions.map((t) => t.toJson()).toList());
    await prefs.setString(_transactionsKey, encoded);
  }

  Future<List<CategoryItem>> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_categoriesKey);
    if (rawJson == null || rawJson.isEmpty) {
      return CategoryItem.defaultCategories;
    }

    try {
      final List<dynamic> decoded = jsonDecode(rawJson);
      final list = decoded.map((c) => CategoryItem.fromJson(c as Map<String, dynamic>)).toList();
      return list.isEmpty ? CategoryItem.defaultCategories : list;
    } catch (e) {
      return CategoryItem.defaultCategories;
    }
  }

  Future<void> saveCategories(List<CategoryItem> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(categories.map((c) => c.toJson()).toList());
    await prefs.setString(_categoriesKey, encoded);
  }

  Future<BudgetsConfig> loadBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_budgetsKey);
    if (rawJson == null || rawJson.isEmpty) {
      return BudgetsConfig.defaultBudgets();
    }

    try {
      final decoded = jsonDecode(rawJson);
      return BudgetsConfig.fromJson(decoded as Map<String, dynamic>);
    } catch (e) {
      return BudgetsConfig.defaultBudgets();
    }
  }

  Future<void> saveBudgets(BudgetsConfig budgets) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(budgets.toJson());
    await prefs.setString(_budgetsKey, encoded);
  }

  Future<UserSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_settingsKey);
    if (rawJson == null || rawJson.isEmpty) {
      return const UserSettings();
    }

    try {
      final decoded = jsonDecode(rawJson);
      return UserSettings.fromJson(decoded as Map<String, dynamic>);
    } catch (e) {
      return const UserSettings();
    }
  }

  Future<void> saveSettings(UserSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(settings.toJson());
    await prefs.setString(_settingsKey, encoded);
  }

  Future<void> resetAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  List<TransactionItem> _generateInitialSeedData() {
    final now = DateTime.now();

    return [
      TransactionItem(
        title: 'Monthly Salary',
        amount: 4500.00,
        date: DateTime(now.year, now.month, 1, 9, 30),
        categoryId: 'salary',
        type: TransactionType.income,
        paymentMethod: PaymentMethod.bankTransfer,
        notes: 'Monthly corporate salary payout',
      ),
      TransactionItem(
        title: 'Freelance UI/UX Project',
        amount: 850.00,
        date: DateTime(now.year, now.month, 4, 14, 00),
        categoryId: 'business',
        type: TransactionType.income,
        paymentMethod: PaymentMethod.online,
        notes: 'Mobile app redesign client milestone',
      ),
      TransactionItem(
        title: 'Supermarket Groceries',
        amount: 145.20,
        date: DateTime(now.year, now.month, 5, 17, 30),
        categoryId: 'groceries',
        type: TransactionType.expense,
        paymentMethod: PaymentMethod.creditCard,
        notes: 'Weekly whole foods & organic produce',
      ),
      TransactionItem(
        title: 'High-Speed Fiber Internet',
        amount: 65.00,
        date: DateTime(now.year, now.month, 8, 10, 15),
        categoryId: 'bills',
        type: TransactionType.expense,
        paymentMethod: PaymentMethod.debitCard,
        notes: 'Monthly Gigabit broadband plan',
      ),
      TransactionItem(
        title: 'Artisan Cafe & Bakery',
        amount: 24.50,
        date: DateTime(now.year, now.month, 10, 8, 45),
        categoryId: 'food',
        type: TransactionType.expense,
        paymentMethod: PaymentMethod.cash,
        notes: 'Coffee & pastries with team',
      ),
      TransactionItem(
        title: 'Tech Gadget Purchase',
        amount: 189.99,
        date: DateTime(now.year, now.month, 12, 16, 20),
        categoryId: 'shopping',
        type: TransactionType.expense,
        paymentMethod: PaymentMethod.creditCard,
        notes: 'Wireless noise cancelling headphones',
      ),
      TransactionItem(
        title: 'Uber Rides to Downtown',
        amount: 32.40,
        date: DateTime(now.year, now.month, 15, 19, 10),
        categoryId: 'transport',
        type: TransactionType.expense,
        paymentMethod: PaymentMethod.online,
        notes: 'Commute during rainy evening',
      ),
      TransactionItem(
        title: 'Quarterly Stock Dividend',
        amount: 120.00,
        date: DateTime(now.year, now.month, 18, 11, 00),
        categoryId: 'investment',
        type: TransactionType.income,
        paymentMethod: PaymentMethod.bankTransfer,
        notes: 'Index fund dividend payout',
      ),
      TransactionItem(
        title: 'Italian Bistro Dinner',
        amount: 88.50,
        date: DateTime(now.year, now.month, 20, 20, 30),
        categoryId: 'food',
        type: TransactionType.expense,
        paymentMethod: PaymentMethod.creditCard,
        notes: 'Weekend dinner with friends',
      ),
      TransactionItem(
        title: 'Streaming Subscriptions',
        amount: 29.99,
        date: DateTime(now.year, now.month, 22, 13, 00),
        categoryId: 'entertainment',
        type: TransactionType.expense,
        paymentMethod: PaymentMethod.debitCard,
        notes: 'Netflix 4K & Spotify Family bundle',
      ),
      TransactionItem(
        title: 'Online Tech Book & Course',
        amount: 45.00,
        date: DateTime(now.year, now.month, 24, 15, 40),
        categoryId: 'education',
        type: TransactionType.expense,
        paymentMethod: PaymentMethod.online,
        notes: 'Flutter Architecture Masterclass',
      ),
      TransactionItem(
        title: 'Pharmacy & Vitamins',
        amount: 38.75,
        date: DateTime(now.year, now.month, 26, 12, 10),
        categoryId: 'health',
        type: TransactionType.expense,
        paymentMethod: PaymentMethod.cash,
        notes: 'Monthly vitamins and supplements',
      ),
    ];
  }
}
