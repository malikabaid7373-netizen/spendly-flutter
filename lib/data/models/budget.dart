class Budget {
  const Budget({required this.categoryKey, required this.limit});

  final String categoryKey;
  final double limit;

  Map<String, Object?> toMap() => {'category_key': categoryKey, 'limit_amount': limit};

  factory Budget.fromMap(Map<String, Object?> map) {
    return Budget(categoryKey: map['category_key']! as String, limit: (map['limit_amount']! as num).toDouble());
  }
}
