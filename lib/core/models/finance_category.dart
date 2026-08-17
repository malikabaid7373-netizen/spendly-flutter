import 'package:flutter/material.dart';

class FinanceCategory {
  const FinanceCategory({required this.key, required this.icon, required this.color});

  final String key;
  final IconData icon;
  final Color color;

  static const food = FinanceCategory(key: 'food', icon: Icons.restaurant_rounded, color: Color(0xFFFFA94D));
  static const transport = FinanceCategory(key: 'transport', icon: Icons.directions_car_filled_rounded, color: Color(0xFF4DABF7));
  static const shopping = FinanceCategory(key: 'shopping', icon: Icons.shopping_bag_rounded, color: Color(0xFFB197FC));
  static const bills = FinanceCategory(key: 'bills', icon: Icons.receipt_long_rounded, color: Color(0xFF74C0FC));
  static const health = FinanceCategory(key: 'health', icon: Icons.favorite_rounded, color: Color(0xFFFF8787));
  static const housing = FinanceCategory(key: 'housing', icon: Icons.home_rounded, color: Color(0xFF20C997));
  static const entertainment = FinanceCategory(key: 'entertainment', icon: Icons.sports_esports_rounded, color: Color(0xFFE599F7));
  static const salary = FinanceCategory(key: 'salary', icon: Icons.account_balance_wallet_rounded, color: Color(0xFF32D79A));
  static const freelance = FinanceCategory(key: 'freelance', icon: Icons.laptop_mac_rounded, color: Color(0xFF39D7E7));
  static const other = FinanceCategory(key: 'other', icon: Icons.more_horiz_rounded, color: Color(0xFF94A3B8));

  static const expenses = [food, transport, shopping, bills, health, housing, entertainment, other];
  static const incomes = [salary, freelance, other];
  static const all = [food, transport, shopping, bills, health, housing, entertainment, salary, freelance, other];

  static FinanceCategory byKey(String key) {
    return all.firstWhere((category) => category.key == key, orElse: () => other);
  }
}
