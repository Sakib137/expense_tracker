import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/expense_list/expense_list.dart';
import 'package:expense_tracker/widgets/new_expense.dart';
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
      amount: 6.99,
      date: DateTime.now(),
      category: Category.work,
    ),

    Expense(
      title: "Ticket",
      amount: 7.99,
      date: DateTime.now(),
      category: Category.travel,
    ),

    Expense(
      title: "Movie",
      amount: 7.99,
      date: DateTime.now(),
      category: Category.leisure,
    ),

    Expense(
      title: "Pizza",
      amount: 5.99,
      date: DateTime.now(),
      category: Category.food,
    ),
  ];

  void _openAddExpenseOverlay() {
    showModalBottomSheet(
      context: context,
      builder: ((context) => NewExpense()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Expense Tracker"),
        actions: [
          IconButton(onPressed: _openAddExpenseOverlay, icon: Icon(Icons.add)),
        ],
      ),
      body: Column(
        children: [
          Text("Expense chart"),
          Expanded(child: ExpenseList(expenses: _registeredExpenses)),
        ],
      ),
    );
  }
}
