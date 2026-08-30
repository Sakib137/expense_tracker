import 'package:flutter/material.dart';

class UserSettings {
  final String currencySymbol;
  final ThemeMode themeMode;
  final String userName;
  final String? profileImagePath;

  const UserSettings({
    this.currencySymbol = '\$',
    this.themeMode = ThemeMode.system,
    this.userName = 'Alex',
    this.profileImagePath,
  });

  UserSettings copyWith({
    String? currencySymbol,
    ThemeMode? themeMode,
    String? userName,
    String? profileImagePath,
    bool clearProfileImage = false,
  }) {
    return UserSettings(
      currencySymbol: currencySymbol ?? this.currencySymbol,
      themeMode: themeMode ?? this.themeMode,
      userName: userName ?? this.userName,
      profileImagePath: clearProfileImage
          ? null
          : (profileImagePath ?? this.profileImagePath),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currencySymbol': currencySymbol,
      'themeMode': themeMode.name,
      'userName': userName,
      'profileImagePath': profileImagePath,
    };
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    ThemeMode mode = ThemeMode.system;
    if (json['themeMode'] == 'dark') {
      mode = ThemeMode.dark;
    } else if (json['themeMode'] == 'light') {
      mode = ThemeMode.light;
    }

    return UserSettings(
      currencySymbol: json['currencySymbol'] as String? ?? '\$',
      themeMode: mode,
      userName: json['userName'] as String? ?? 'Alex',
      profileImagePath: json['profileImagePath'] as String?,
    );
  }

  static const List<String> supportedCurrencies = [
    '\$', // USD, CAD, AUD
    '€',  // EUR
    '£',  // GBP
    '¥',  // JPY, CNY
    '৳',  // BDT
    '₹',  // INR
    '₩',  // KRW
    '₺',  // TRY
    'R\$', // BRL
    'Fr', // CHF
  ];
}
