enum TransactionType { income, expense }

class FinanceTransaction {
  const FinanceTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryKey,
    required this.date,
    this.note = '',
    this.isRecurring = false,
  });

  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String categoryKey;
  final DateTime date;
  final String note;
  final bool isRecurring;

  FinanceTransaction copyWith({String? title, double? amount, TransactionType? type, String? categoryKey, DateTime? date, String? note, bool? isRecurring}) {
    return FinanceTransaction(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryKey: categoryKey ?? this.categoryKey,
      date: date ?? this.date,
      note: note ?? this.note,
      isRecurring: isRecurring ?? this.isRecurring,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'amount': amount,
        'type': type.name,
        'category_key': categoryKey,
        'date': date.toIso8601String(),
        'note': note,
        'is_recurring': isRecurring ? 1 : 0,
      };

  factory FinanceTransaction.fromMap(Map<String, Object?> map) {
    return FinanceTransaction(
      id: map['id']! as String,
      title: map['title']! as String,
      amount: (map['amount']! as num).toDouble(),
      type: TransactionType.values.byName(map['type']! as String),
      categoryKey: map['category_key']! as String,
      date: DateTime.parse(map['date']! as String),
      note: (map['note'] as String?) ?? '',
      isRecurring: (map['is_recurring'] as int? ?? 0) == 1,
    );
  }
}
