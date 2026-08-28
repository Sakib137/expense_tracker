import 'package:expense_tracker/expense.dart';
import 'package:flutter/material.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  final List<Expense> _registeredExpenses = [
    Expense(
      title: "flutter course",
      amount: 9.99,
      date: DateTime.now(),
      category: Category.work,
    ),

    Expense(
      title: "web course",
      amount: 7.99,
      date: DateTime.now(),
      category: Category.work,
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Column(children: [Text("hello"), Text("sakib")]));
  }
}
