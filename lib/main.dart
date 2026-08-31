import 'package:flutter/material.dart';
import 'package:expense_tracker/state/app_state.dart';
import 'package:expense_tracker/state/app_state_provider.dart';
import 'package:expense_tracker/theme/app_theme.dart';
import 'package:expense_tracker/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = AppState();

  runApp(
    AppStateProvider(appState: appState, child: const ExpenseTrackerApp()),
  );
}

class ExpenseTrackerApp extends StatelessWidget {
  final Widget? initialScreen;

  const ExpenseTrackerApp({
    super.key,
    this.initialScreen,
  });

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);

    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: appState.themeMode,
      home: initialScreen ?? const SplashScreen(),
    );
  }
}

