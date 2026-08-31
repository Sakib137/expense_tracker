import 'package:flutter/material.dart';
import 'package:expense_tracker/utils/icon_helper.dart';

enum CategoryType {
  expense,
  income,
}

class CategoryItem {
  final String id;
  final String name;
  final String iconKey;
  final int colorValue;
  final CategoryType type;
  final bool isCustom;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.colorValue,
    required this.type,
    this.isCustom = false,
  });

  IconData get icon => IconHelper.getIcon(iconKey);
  Color get color => Color(colorValue);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconKey': iconKey,
      'colorValue': colorValue,
      'type': type.name,
      'isCustom': isCustom,
    };
  }

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: json['id'] as String? ?? 'custom_unknown',
      name: json['name'] as String? ?? 'Custom Category',
      iconKey: json['iconKey'] as String? ?? 'category',
      colorValue: json['colorValue'] as int? ?? 0xFF64748B,
      type: json['type'] == 'income' ? CategoryType.income : CategoryType.expense,
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }

  static List<CategoryItem> get defaultCategories => [
    // Expense Categories
    const CategoryItem(
      id: 'food',
      name: 'Food & Dining',
      iconKey: 'restaurant',
      colorValue: 0xFFEF4444, // Red
      type: CategoryType.expense,
    ),
    const CategoryItem(
      id: 'transport',
      name: 'Transportation',
      iconKey: 'directions_car',
      colorValue: 0xFF06B6D4, // Cyan
      type: CategoryType.expense,
    ),
    const CategoryItem(
      id: 'shopping',
      name: 'Shopping',
      iconKey: 'shopping_bag',
      colorValue: 0xFFF59E0B, // Amber
      type: CategoryType.expense,
    ),
    const CategoryItem(
      id: 'entertainment',
      name: 'Entertainment',
      iconKey: 'movie',
      colorValue: 0xFF8B5CF6, // Purple
      type: CategoryType.expense,
    ),
    const CategoryItem(
      id: 'bills',
      name: 'Bills & Utilities',
      iconKey: 'receipt_long',
      colorValue: 0xFF3B82F6, // Blue
      type: CategoryType.expense,
    ),
    const CategoryItem(
      id: 'health',
      name: 'Health & Medical',
      iconKey: 'medical_services',
      colorValue: 0xFF14B8A6, // Teal
      type: CategoryType.expense,
    ),
    const CategoryItem(
      id: 'education',
      name: 'Education',
      iconKey: 'school',
      colorValue: 0xFF6366F1, // Indigo
      type: CategoryType.expense,
    ),
    const CategoryItem(
      id: 'groceries',
      name: 'Groceries',
      iconKey: 'shopping_cart',
      colorValue: 0xFF10B981, // Emerald
      type: CategoryType.expense,
    ),
    const CategoryItem(
      id: 'expense_other',
      name: 'Other Expense',
      iconKey: 'category',
      colorValue: 0xFF64748B, // Slate
      type: CategoryType.expense,
    ),

    // Income Categories
    const CategoryItem(
      id: 'salary',
      name: 'Salary',
      iconKey: 'payments',
      colorValue: 0xFF10B981, // Emerald
      type: CategoryType.income,
    ),
    const CategoryItem(
      id: 'business',
      name: 'Business & Freelancing',
      iconKey: 'work',
      colorValue: 0xFF84CC16, // Lime
      type: CategoryType.income,
    ),
    const CategoryItem(
      id: 'investment',
      name: 'Investment & Dividends',
      iconKey: 'trending_up',
      colorValue: 0xFF06B6D4, // Cyan
      type: CategoryType.income,
    ),
    const CategoryItem(
      id: 'gift',
      name: 'Gifts & Rewards',
      iconKey: 'card_giftcard',
      colorValue: 0xFFEC4899, // Pink
      type: CategoryType.income,
    ),
    const CategoryItem(
      id: 'income_other',
      name: 'Other Income',
      iconKey: 'account_balance_wallet',
      colorValue: 0xFF64748B, // Slate
      type: CategoryType.income,
    ),
  ];
}
