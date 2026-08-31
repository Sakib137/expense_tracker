# 💰 Expense Tracker - Personal Finance & Budget Management

<div align="center">

<img src="assets/images/app_logo.png" alt="Expense Tracker Logo" width="140" height="140" style="border-radius: 28px;" />

### *Track • Save • Grow*

A modern, offline-first personal finance application built with **Flutter & Dart**. Effortlessly track income and expenses, visualize financial health with interactive charts, set smart budget limits, and gain actionable spending insights.

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20macOS%20%7C%20Web-4E73DF?style=for-the-badge)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)
[![Tests](https://img.shields.io/badge/Tests-11%20Passed-brightgreen?style=for-the-badge)]()

</div>

---

## 📱 Screenshots & UI Showcase

> 📂 **Full High-Resolution UI Screenshot Gallery**:  
> 👉 [**View App Screenshots on Google Drive**](https://drive.google.com/drive/u/0/folders/1YGJ30IlrfHPLDdEf3DLwpphQT0YBvtMD)

---

## ✨ Key Features

### 🏠 1. Interactive Dashboard
- **Hero Balance Card**: Real-time overview of your total balance, monthly income, monthly expenses, and savings rate.
- **Quick Action Bar**: One-tap shortcuts to log an expense, record income, adjust budgets, or inspect analytics.
- **Budget Alerts**: Visual warning banners when approaching or exceeding category and monthly limits.
- **Smart Insights**: Rule-based financial highlights detecting top spending habits and savings trends.
- **Recent Activity**: Quick view of recent transactions with swipe-to-delete and a 3-second auto-dismiss undo SnackBar.

### 📝 2. Transaction Management & History
- **Full-Text Search & Filters**: Filter transactions by type (*All, Income, Expense*) or drill down by category.
- **Detailed Transaction Logger**: Add and edit entries with title, amount, custom date, category, payment method (*Cash, Debit Card, Credit Card, Bank Transfer, Online/Digital*), and optional notes.
- **Interactive Details Dialog**: Inspect detailed transaction receipts with category colors, icons, and timestamp.
- **Swipe-to-Delete**: Seamless dismissible interactions with undo recovery.

### 📊 3. Rich Financial Analytics & Charts
- **Timeframe Selector**: Dynamically filter analytics by **Week**, **Month**, **Year**, or **All Time**.
- **Spending Distribution (Pie Chart)**: Touch-interactive breakdown of expenses by category with percentages and legends powered by `fl_chart`.
- **Income vs Expenses (Bar Chart)**: 6-month historical comparison tracking income against expenditure.
- **Spending Trends (Line Chart)**: Smooth curved trendlines tracking spending trajectory over time.
- **KPI Metrics**: Real-time cards calculating Total Income, Total Expense, Net Savings, and Savings Rate.

### 🎯 4. Smart Budgeting & Limits
- **Monthly Overall Budget**: Set global spending caps with real-time progress indicators and status badges (*Normal*, *Warning >80%*, *Exceeded 100%+*).
- **Category-Level Budgets**: Set dedicated limits for specific categories (Food, Shopping, Bills, Transport, etc.).
- **Visual Over-Budget Warnings**: Color-coded progress bars alerting you before overspending happens.

### ⚙️ 5. Personalization & Settings
- **Profile Customization**: Customize display name and pick profile pictures via Camera or Gallery (`image_picker`).
- **Multi-Currency Support**: Switch between USD (`$`), EUR (`€`), GBP (`£`), JPY (`¥`), INR (`₹`), BDT (`৳`), CAD (`$`), AUD (`$`), and more.
- **Dark & Light Mode**: Seamless theme switching with system auto-detection and custom palette styling.
- **Custom Category Creator**: Add custom categories with a choice of 28+ icons and curated color palettes.
- **Animated Splash Screen**: Smooth brand entrance animation with tap-to-skip support.

---

## 🏗️ Architecture & Project Structure

The project follows a clean, modular, and maintainable layered architecture:

```text
lib/
├── main.dart                  # Application entrypoint & AppState provider root
├── models/                    # Data models with resilient JSON serialization
│   ├── budget_item.dart       # Budget limits & status calculation
│   ├── category_item.dart     # Categories, icon keys, colors
│   ├── transaction_item.dart  # Transaction model & payment method enum
│   └── user_settings.dart     # User profile, theme, and currency settings
├── repositories/              # Repository layer coordinating storage operations
│   └── expense_repository.dart
├── screens/                   # Top-level application screens
│   ├── analytics_screen.dart  # Charts, KPIs & financial insights
│   ├── budgets_screen.dart    # Overall & category budget management
│   ├── dashboard_screen.dart  # Balance hero, quick actions, recent items
│   ├── main_scaffold.dart     # Bottom navigation scaffold
│   ├── settings_screen.dart   # Profile, currencies, theme, categories
│   ├── splash_screen.dart     # Animated entrance splash screen
│   └── transactions_screen.dart # History, filters, search
├── services/                  # Persistent local storage
│   └── storage_service.dart   # SharedPreferences JSON persistence
├── state/                     # State management (ChangeNotifier & Provider)
│   ├── app_state.dart         # Core business logic, analytics calculations, CRUD
│   └── app_state_provider.dart # InheritedWidget provider
├── theme/                     # Design tokens & Material 3 theme configurations
│   ├── app_colors.dart        # Curated color palettes
│   └── app_theme.dart         # Light & Dark theme definitions
├── utils/                     # Helper utilities
│   ├── currency_formatter.dart # Currency formatting & compact notation
│   ├── date_helpers.dart      # Relative formatting & period predicates
│   └── icon_helper.dart       # Dynamic icon mapping
└── widgets/                   # Reusable UI component library
    ├── analytics/             # Charts (Pie, Bar, Line) & Insights
    ├── budgets/               # Budget cards & edit sheets
    ├── common/                # Metric cards, custom cards, avatars
    ├── dashboard/             # Balance card & quick action buttons
    └── transactions/          # Add/Edit sheets, tiles, receipts
```

---

## 🛠️ Tech Stack & Dependencies

| Package | Version | Purpose |
| :--- | :--- | :--- |
| [**Flutter**](https://flutter.dev) | `3.12+` | Cross-platform UI toolkit |
| [**fl_chart**](https://pub.dev/packages/fl_chart) | `^1.2.0` | Interactive spending pie, bar, and trend line charts |
| [**shared_preferences**](https://pub.dev/packages/shared_preferences) | `^2.5.5` | Fast, offline-first local data persistence |
| [**image_picker**](https://pub.dev/packages/image_picker) | `^1.2.3` | User profile avatar selection from gallery/camera |
| [**intl**](https://pub.dev/packages/intl) | `^0.20.3` | Date formatting and currency formatting |
| [**uuid**](https://pub.dev/packages/uuid) | `^4.6.0` | Unique identifier generation for transactions and categories |
| [**flutter_launcher_icons**](https://pub.dev/packages/flutter_launcher_icons) | `^0.14.4` | Automated cross-platform app icon generation |

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.12.2`)
- [Dart SDK](https://dart.dev/get-dart)
- Xcode (for iOS / macOS builds) or Android Studio (for Android builds)

### 1. Clone the Repository
```bash
git clone https://github.com/Sakib137/expense_tracker.git
cd expense_tracker
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run Platform Icon Generator *(Optional)*
```bash
dart run flutter_launcher_icons
```

### 4. Run the App
```bash
# Run on an active simulator / connected device
flutter run

# Or specify a target device (e.g., iPhone simulator, Chrome, macOS)
flutter run -d "iPhone 16 Pro"
flutter run -d chrome
flutter run -d macos
```

---

## 🧪 Testing & Code Quality

The project includes an automated test suite covering model serialization, budget algorithms, state mutations, calculations, and widget rendering.

```bash
# Run static analysis
flutter analyze

# Run all unit and widget tests
flutter test
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<div align="center">
  <sub>Built with ❤️ using Flutter & Dart.</sub>
</div>
