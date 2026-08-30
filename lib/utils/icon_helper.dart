import 'package:flutter/material.dart';

class IconHelper {
  static const Map<String, IconData> availableIcons = {
    'fastfood': Icons.fastfood_rounded,
    'restaurant': Icons.restaurant_rounded,
    'shopping_bag': Icons.shopping_bag_rounded,
    'shopping_cart': Icons.shopping_cart_rounded,
    'directions_car': Icons.directions_car_rounded,
    'flight': Icons.flight_takeoff_rounded,
    'train': Icons.train_rounded,
    'local_gas_station': Icons.local_gas_station_rounded,
    'movie': Icons.movie_rounded,
    'sports_esports': Icons.sports_esports_rounded,
    'fitness_center': Icons.fitness_center_rounded,
    'medical_services': Icons.medical_services_rounded,
    'school': Icons.school_rounded,
    'receipt_long': Icons.receipt_long_rounded,
    'bolt': Icons.bolt_rounded,
    'water_drop': Icons.water_drop_rounded,
    'wifi': Icons.wifi_rounded,
    'work': Icons.work_rounded,
    'account_balance_wallet': Icons.account_balance_wallet_rounded,
    'account_balance': Icons.account_balance_rounded,
    'attach_money': Icons.attach_money_rounded,
    'payments': Icons.payments_rounded,
    'trending_up': Icons.trending_up_rounded,
    'house': Icons.home_rounded,
    'card_giftcard': Icons.card_giftcard_rounded,
    'pets': Icons.pets_rounded,
    'coffee': Icons.coffee_rounded,
    'local_mall': Icons.local_mall_rounded,
    'category': Icons.category_rounded,
  };

  static IconData getIcon(String key) {
    return availableIcons[key] ?? Icons.category_rounded;
  }

  static String getKey(IconData icon) {
    for (final entry in availableIcons.entries) {
      if (entry.value.codePoint == icon.codePoint) {
        return entry.key;
      }
    }
    return 'category';
  }
}
