enum BudgetStatus {
  normal,
  warning,
  exceeded,
}

class CategoryBudget {
  final String categoryId;
  final double monthlyLimit;

  const CategoryBudget({
    required this.categoryId,
    required this.monthlyLimit,
  });

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'monthlyLimit': monthlyLimit,
    };
  }

  factory CategoryBudget.fromJson(Map<String, dynamic> json) {
    return CategoryBudget(
      categoryId: json['categoryId'] as String,
      monthlyLimit: (json['monthlyLimit'] as num).toDouble(),
    );
  }
}

class BudgetsConfig {
  final double overallMonthlyBudget;
  final Map<String, double> categoryBudgets; // categoryId -> limit

  const BudgetsConfig({
    required this.overallMonthlyBudget,
    required this.categoryBudgets,
  });

  static BudgetsConfig defaultBudgets() {
    return const BudgetsConfig(
      overallMonthlyBudget: 2500.0,
      categoryBudgets: {
        'food': 600.0,
        'transport': 250.0,
        'shopping': 400.0,
        'entertainment': 200.0,
        'bills': 500.0,
        'groceries': 350.0,
      },
    );
  }

  BudgetsConfig copyWith({
    double? overallMonthlyBudget,
    Map<String, double>? categoryBudgets,
  }) {
    return BudgetsConfig(
      overallMonthlyBudget: overallMonthlyBudget ?? this.overallMonthlyBudget,
      categoryBudgets: categoryBudgets ?? Map.from(this.categoryBudgets),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overallMonthlyBudget': overallMonthlyBudget,
      'categoryBudgets': categoryBudgets,
    };
  }

  factory BudgetsConfig.fromJson(Map<String, dynamic> json) {
    final rawCategoryBudgets = json['categoryBudgets'] as Map<String, dynamic>? ?? {};
    final convertedCategoryBudgets = <String, double>{};
    for (final entry in rawCategoryBudgets.entries) {
      if (entry.value is num) {
        convertedCategoryBudgets[entry.key] = (entry.value as num).toDouble();
      }
    }

    return BudgetsConfig(
      overallMonthlyBudget: (json['overallMonthlyBudget'] as num?)?.toDouble() ?? 2500.0,
      categoryBudgets: convertedCategoryBudgets,
    );
  }

  static BudgetStatus calculateStatus({required double spent, required double limit}) {
    if (limit <= 0) return BudgetStatus.normal;
    final ratio = spent / limit;
    if (ratio >= 1.0) {
      return BudgetStatus.exceeded;
    } else if (ratio >= 0.8) {
      return BudgetStatus.warning;
    }
    return BudgetStatus.normal;
  }
}
