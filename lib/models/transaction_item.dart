import 'package:uuid/uuid.dart';

enum TransactionType {
  expense,
  income,
}

enum PaymentMethod {
  cash,
  debitCard,
  creditCard,
  bankTransfer,
  online,
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.debitCard:
        return 'Debit Card';
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.online:
        return 'Online / Digital';
    }
  }
}

class TransactionItem {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String categoryId;
  final TransactionType type;
  final PaymentMethod paymentMethod;
  final String? notes;

  TransactionItem({
    String? id,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
    required this.type,
    this.paymentMethod = PaymentMethod.cash,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  bool get isExpense => type == TransactionType.expense;
  bool get isIncome => type == TransactionType.income;

  TransactionItem copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    String? categoryId,
    TransactionType? type,
    PaymentMethod? paymentMethod,
    String? notes,
  }) {
    return TransactionItem(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'categoryId': categoryId,
      'type': type.name,
      'paymentMethod': paymentMethod.name,
      'notes': notes,
    };
  }

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate = DateTime.now();
    if (json['date'] != null) {
      final parsed = DateTime.tryParse(json['date'].toString());
      if (parsed != null) {
        parsedDate = parsed;
      }
    }

    return TransactionItem(
      id: json['id'] as String? ?? const Uuid().v4(),
      title: json['title'] as String? ?? 'Untitled Transaction',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: parsedDate,
      categoryId: json['categoryId'] as String? ?? 'expense_other',
      type: json['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      paymentMethod: PaymentMethod.values.firstWhere(
        (m) => m.name == json['paymentMethod'],
        orElse: () => PaymentMethod.cash,
      ),
      notes: json['notes'] as String?,
    );
  }
}
