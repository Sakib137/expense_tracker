import 'package:flutter/material.dart';

class AppColors {
  // Brand / Primary Colors
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryGradientStart = Color(0xFF6366F1);
  static const Color primaryGradientEnd = Color(0xFF8B5CF6);

  // Semantic Financial Colors
  static const Color income = Color(0xFF10B981); // Emerald
  static const Color incomeLight = Color(0xFFD1FAE5);
  static const Color incomeDark = Color(0xFF047857);

  static const Color expense = Color(0xFFF43F5E); // Rose
  static const Color expenseLight = Color(0xFFFFE4E6);
  static const Color expenseDark = Color(0xFFBE123C);

  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color info = Color(0xFF3B82F6); // Blue

  // Dark Theme Backgrounds & Surfaces
  static const Color darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color darkSurface = Color(0xFF1E293B); // Slate 800
  static const Color darkSurfaceVariant = Color(0xFF334155); // Slate 700
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextTertiary = Color(0xFF64748B);

  // Light Theme Backgrounds & Surfaces
  static const Color lightBackground = Color(0xFFF8FAFC); // Slate 50
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9); // Slate 100
  static const Color lightBorder = Color(0xFFE2E8F0); // Slate 200
  static const Color lightTextPrimary = Color(0xFF0F172A); // Slate 900
  static const Color lightTextSecondary = Color(0xFF64748B); // Slate 500
  static const Color lightTextTertiary = Color(0xFF94A3B8); // Slate 400

  // Category Color Palette
  static const List<Color> categoryPalette = [
    Color(0xFFEF4444), // Red (Food & Dining)
    Color(0xFFF97316), // Orange (Fast Food/Snacks)
    Color(0xFFF59E0B), // Amber (Shopping)
    Color(0xFF10B981), // Emerald (Salary / Income)
    Color(0xFF14B8A6), // Teal (Health & Medical)
    Color(0xFF06B6D4), // Cyan (Transportation)
    Color(0xFF3B82F6), // Blue (Bills & Utilities)
    Color(0xFF6366F1), // Indigo (Education)
    Color(0xFF8B5CF6), // Purple (Entertainment)
    Color(0xFFEC4899), // Pink (Personal Care)
    Color(0xFF84CC16), // Lime (Freelance/Business)
    Color(0xFF64748B), // Slate (Other)
  ];
}
