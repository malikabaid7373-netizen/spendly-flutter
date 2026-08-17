import 'package:flutter_test/flutter_test.dart';
import 'package:spendly/data/models/finance_transaction.dart';

void main() {
  test('FinanceTransaction maps to and from database values', () {
    final original = FinanceTransaction(
      id: '1',
      title: 'Lunch',
      amount: 35,
      type: TransactionType.expense,
      categoryKey: 'food',
      date: DateTime(2026, 8, 13),
      note: 'Team lunch',
      isRecurring: false,
    );
    final restored = FinanceTransaction.fromMap(original.toMap());
    expect(restored.id, original.id);
    expect(restored.amount, original.amount);
    expect(restored.type, TransactionType.expense);
    expect(restored.categoryKey, 'food');
  });
}
