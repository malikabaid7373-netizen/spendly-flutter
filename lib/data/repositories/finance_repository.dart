import '../models/budget.dart';
import '../models/finance_transaction.dart';
import '../services/local_database_service.dart';

class FinanceRepository {
  const FinanceRepository(this._service);
  final LocalDatabaseService _service;

  Future<List<FinanceTransaction>> getTransactions() => _service.getTransactions();
  Future<List<Budget>> getBudgets() => _service.getBudgets();
  Future<void> saveTransaction(FinanceTransaction transaction) => _service.upsertTransaction(transaction);
  Future<void> deleteTransaction(String id) => _service.deleteTransaction(id);
  Future<void> saveBudget(Budget budget) => _service.upsertBudget(budget);
  Future<void> seedData({
    required List<FinanceTransaction> transactions,
    required List<Budget> budgets,
    bool clearFirst = false,
  }) =>
      _service.seedFinanceData(
        transactions: transactions,
        budgets: budgets,
        clearFirst: clearFirst,
      );
  Future<void> clear() => _service.clearFinanceData();
}
