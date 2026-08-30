import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/chart/chart.dart';
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
      isScrollControlled: true,
      context: context,
      builder: ((context) => NewExpense(onAddExpense: _addExpense)),
    );
  }

  void _addExpense(Expense expense) {
    setState(() {
      _registeredExpenses.add(expense);
    });
  }

  void _removeExpenses(Expense expense) {
    final expenseIndex = _registeredExpenses.indexOf(expense);

    setState(() {
      _registeredExpenses.remove(expense);
    });

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    scaffoldMessenger.clearSnackBars();

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: const Text("Expense deleted"),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: "Undo",
          onPressed: () {
            setState(() {
              _registeredExpenses.insert(expenseIndex, expense);
            });
          },
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        scaffoldMessenger.hideCurrentSnackBar();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      'Accessible navigation: ${MediaQuery.of(context).accessibleNavigation}',
    );

    Widget mainContent = Center(
      child: Text("No Expense found. Please start adding!"),
    );

    if (_registeredExpenses.isNotEmpty) {
      mainContent = ExpenseList(
        expenses: _registeredExpenses,
        onRemoveExpense: _removeExpenses,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Expense Tracker"),
        actions: [
          IconButton(onPressed: _openAddExpenseOverlay, icon: Icon(Icons.add)),
        ],
      ),
      body: Column(
        children: [
          Chart(expenses: _registeredExpenses),
          Expanded(child: mainContent),
        ],
      ),
    );
  }
}
