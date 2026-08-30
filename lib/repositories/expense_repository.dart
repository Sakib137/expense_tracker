import 'package:expense_tracker/models/transaction_item.dart';
import 'package:expense_tracker/models/category_item.dart';
import 'package:expense_tracker/models/budget_item.dart';
import 'package:expense_tracker/models/user_settings.dart';
import 'package:expense_tracker/services/storage_service.dart';

class ExpenseRepository {
  final StorageService _storageService;

  ExpenseRepository({StorageService? storageService})
      : _storageService = storageService ?? StorageService();

  Future<List<TransactionItem>> getTransactions() => _storageService.loadTransactions();

  Future<void> saveTransactions(List<TransactionItem> transactions) =>
      _storageService.saveTransactions(transactions);

  Future<List<CategoryItem>> getCategories() => _storageService.loadCategories();

  Future<void> saveCategories(List<CategoryItem> categories) =>
      _storageService.saveCategories(categories);

  Future<BudgetsConfig> getBudgets() => _storageService.loadBudgets();

  Future<void> saveBudgets(BudgetsConfig budgets) =>
      _storageService.saveBudgets(budgets);

  Future<UserSettings> getSettings() => _storageService.loadSettings();

  Future<void> saveSettings(UserSettings settings) =>
      _storageService.saveSettings(settings);

  Future<void> resetAll() => _storageService.resetAllData();
}
