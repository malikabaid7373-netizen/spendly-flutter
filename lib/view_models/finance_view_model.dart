import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../data/models/budget.dart';
import '../data/models/finance_transaction.dart';
import '../data/repositories/finance_repository.dart';

class FinanceViewModel extends ChangeNotifier {
  FinanceViewModel(this._repository);

  final FinanceRepository _repository;

  List<FinanceTransaction> _transactions = [];
  List<Budget> _budgets = [];
  List<FinanceTransaction> _currentMonthTransactions = [];
  Map<String, double> _spendingByCategory = {};
  Map<String, double> _budgetByCategory = {};
  List<double> _lastSevenDayExpenseTrend = List<double>.filled(7, 0);
  List<double> _sixMonthExpenseTrend = List<double>.filled(6, 0);

  bool _loading = false;
  double _totalIncome = 0;
  double _totalExpenses = 0;
  double _monthIncome = 0;
  double _monthExpenses = 0;
  double _totalBudget = 0;
  double _weeklyExpenses = 0;
  double _recurringExpenses = 0;
  double _previousMonthExpenses = 0;
  int _noSpendDaysThisWeek = 7;
  int _activeBudgetCount = 0;
  String? _largestExpenseCategory;

  List<FinanceTransaction> get transactions =>
      UnmodifiableListView<FinanceTransaction>(_transactions);
  List<Budget> get budgets => UnmodifiableListView<Budget>(_budgets);
  List<FinanceTransaction> get currentMonthTransactions =>
      UnmodifiableListView<FinanceTransaction>(_currentMonthTransactions);
  Map<String, double> get spendingByCategory =>
      UnmodifiableMapView<String, double>(_spendingByCategory);
  bool get isLoading => _loading;

  double get totalIncome => _totalIncome;
  double get totalExpenses => _totalExpenses;
  double get balance => _totalIncome - _totalExpenses;
  double get monthIncome => _monthIncome;
  double get monthExpenses => _monthExpenses;
  double get totalBudget => _totalBudget;
  double get weeklyExpenses => _weeklyExpenses;
  int get noSpendDaysThisWeek => _noSpendDaysThisWeek;
  double get recurringExpenses => _recurringExpenses;
  double get previousMonthExpenses => _previousMonthExpenses;
  int get activeBudgetCount => _activeBudgetCount;
  String? get largestExpenseCategory => _largestExpenseCategory;
  List<double> get lastSevenDayExpenseTrend =>
      UnmodifiableListView<double>(_lastSevenDayExpenseTrend);

  double get budgetRemaining =>
      (_totalBudget - _monthExpenses).clamp(0, double.infinity).toDouble();

  double get budgetProgress => _totalBudget <= 0
      ? 0
      : (_monthExpenses / _totalBudget).clamp(0, 1.5).toDouble();

  double get savingsRate => _monthIncome <= 0
      ? 0
      : ((_monthIncome - _monthExpenses) / _monthIncome * 100)
          .clamp(-100, 100)
          .toDouble();

  double get projectedMonthExpenses {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    return _monthExpenses / now.day * daysInMonth;
  }

  double get monthOverMonthChange {
    if (_previousMonthExpenses <= 0) {
      return _monthExpenses > 0 ? 100 : 0;
    }
    return ((_monthExpenses - _previousMonthExpenses) /
                _previousMonthExpenses *
                100)
            .clamp(-999, 999)
            .toDouble();
  }

  int get financialHealthScore {
    final savingsComponent = savingsRate.clamp(-50, 50).toDouble() * .55;
    final budgetComponent = _totalBudget <= 0
        ? 0.0
        : (1 - budgetProgress).clamp(-.5, 1).toDouble() * 25;
    return (55 + savingsComponent + budgetComponent)
        .round()
        .clamp(0, 100)
        .toInt();
  }

  String get healthLevelKey {
    final score = financialHealthScore;
    if (score >= 85) return 'excellent';
    if (score >= 70) return 'good';
    if (score >= 50) return 'fair';
    return 'watch';
  }

  Future<void> load() async {
    _loading = true;
    _transactions = await _repository.getTransactions();
    _budgets = await _repository.getBudgets();
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    _rebuildDerivedState();
    _loading = false;
    notifyListeners();
  }

  double categorySpent(String categoryKey) =>
      _spendingByCategory[categoryKey] ?? 0;

  double budgetFor(String categoryKey) => _budgetByCategory[categoryKey] ?? 0;

  Future<void> saveTransaction(FinanceTransaction transaction) async {
    final previousIndex =
        _transactions.indexWhere((item) => item.id == transaction.id);
    final previous = previousIndex >= 0 ? _transactions[previousIndex] : null;

    if (previousIndex >= 0) {
      _transactions[previousIndex] = transaction;
    } else {
      _transactions.add(transaction);
    }
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    _rebuildDerivedState();
    notifyListeners();

    try {
      await _repository.saveTransaction(transaction);
    } catch (_) {
      if (previous != null) {
        final index =
            _transactions.indexWhere((item) => item.id == transaction.id);
        if (index >= 0) _transactions[index] = previous;
      } else {
        _transactions.removeWhere((item) => item.id == transaction.id);
      }
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      _rebuildDerivedState();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteTransaction(String id) async {
    final index = _transactions.indexWhere((item) => item.id == id);
    if (index < 0) return;

    final removed = _transactions.removeAt(index);
    _rebuildDerivedState();
    notifyListeners();

    try {
      await _repository.deleteTransaction(id);
    } catch (_) {
      _transactions.add(removed);
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      _rebuildDerivedState();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> saveBudget(String categoryKey, double limit) async {
    final budget = Budget(categoryKey: categoryKey, limit: limit);
    final index =
        _budgets.indexWhere((item) => item.categoryKey == categoryKey);
    final previous = index >= 0 ? _budgets[index] : null;

    if (index >= 0) {
      _budgets[index] = budget;
    } else {
      _budgets.add(budget);
    }
    _rebuildDerivedState();
    notifyListeners();

    try {
      await _repository.saveBudget(budget);
    } catch (_) {
      if (previous != null) {
        final restoreIndex =
            _budgets.indexWhere((item) => item.categoryKey == categoryKey);
        if (restoreIndex >= 0) _budgets[restoreIndex] = previous;
      } else {
        _budgets.removeWhere((item) => item.categoryKey == categoryKey);
      }
      _rebuildDerivedState();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> seedDemoData({bool force = false}) async {
    if (_transactions.isNotEmpty && !force) return;
    if (force) await _repository.clear();

    final now = DateTime.now();
    final stamp = now.millisecondsSinceEpoch;
    final data = <FinanceTransaction>[
      FinanceTransaction(
        id: 'demo-salary-$stamp',
        title: 'Monthly salary',
        amount: 5200,
        type: TransactionType.income,
        categoryKey: 'salary',
        date: DateTime(now.year, now.month, 1, 9),
        isRecurring: true,
      ),
      FinanceTransaction(
        id: 'demo-freelance-$stamp',
        title: 'Landing page project',
        amount: 850,
        type: TransactionType.income,
        categoryKey: 'freelance',
        date: now.subtract(const Duration(days: 4)),
      ),
      FinanceTransaction(
        id: 'demo-rent-$stamp',
        title: 'Apartment rent',
        amount: 1584,
        type: TransactionType.expense,
        categoryKey: 'housing',
        date: DateTime(now.year, now.month, 2, 12),
        isRecurring: true,
      ),
      FinanceTransaction(
        id: 'demo-grocery-$stamp',
        title: 'Weekly groceries',
        amount: 238,
        type: TransactionType.expense,
        categoryKey: 'food',
        date: now.subtract(const Duration(hours: 5)),
      ),
      FinanceTransaction(
        id: 'demo-fuel-$stamp',
        title: 'Fuel',
        amount: 120,
        type: TransactionType.expense,
        categoryKey: 'transport',
        date: now.subtract(const Duration(days: 1)),
      ),
      FinanceTransaction(
        id: 'demo-electric-$stamp',
        title: 'Electricity bill',
        amount: 193,
        type: TransactionType.expense,
        categoryKey: 'bills',
        date: now.subtract(const Duration(days: 2)),
      ),
      FinanceTransaction(
        id: 'demo-dinner-$stamp',
        title: 'Dinner',
        amount: 46,
        type: TransactionType.expense,
        categoryKey: 'food',
        date: now.subtract(const Duration(days: 2, hours: 3)),
      ),
      FinanceTransaction(
        id: 'demo-pharmacy-$stamp',
        title: 'Pharmacy',
        amount: 65,
        type: TransactionType.expense,
        categoryKey: 'health',
        date: now.subtract(const Duration(days: 5)),
      ),
    ];

    for (var monthOffset = 1; monthOffset <= 5; monthOffset++) {
      final monthDate = DateTime(now.year, now.month - monthOffset, 15);
      data.add(
        FinanceTransaction(
          id: 'demo-history-$monthOffset-$stamp',
          title: 'Monthly spending',
          amount: 1500 + monthOffset * 135,
          type: TransactionType.expense,
          categoryKey: monthOffset.isEven ? 'food' : 'shopping',
          date: monthDate,
        ),
      );
      data.add(
        FinanceTransaction(
          id: 'demo-history-income-$monthOffset-$stamp',
          title: 'Salary',
          amount: 5000,
          type: TransactionType.income,
          categoryKey: 'salary',
          date: DateTime(monthDate.year, monthDate.month, 1),
        ),
      );
    }

    const defaultBudgets = [
      Budget(categoryKey: 'food', limit: 850),
      Budget(categoryKey: 'transport', limit: 450),
      Budget(categoryKey: 'shopping', limit: 600),
      Budget(categoryKey: 'bills', limit: 500),
      Budget(categoryKey: 'health', limit: 300),
      Budget(categoryKey: 'housing', limit: 1700),
      Budget(categoryKey: 'entertainment', limit: 350),
    ];

    await _repository.seedData(
      transactions: data,
      budgets: defaultBudgets,
      clearFirst: force,
    );

    _transactions = [...data]..sort((a, b) => b.date.compareTo(a.date));
    _budgets = [...defaultBudgets];
    _rebuildDerivedState();
    notifyListeners();
  }

  List<double> expenseTrend() =>
      UnmodifiableListView<double>(_sixMonthExpenseTrend);

  void _rebuildDerivedState() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(const Duration(days: 6));
    final previousMonth = DateTime(now.year, now.month - 1);

    _currentMonthTransactions = [];
    _spendingByCategory = {};
    _budgetByCategory = {};
    _lastSevenDayExpenseTrend = List<double>.filled(7, 0);
    _sixMonthExpenseTrend = List<double>.filled(6, 0);
    _totalIncome = 0;
    _totalExpenses = 0;
    _monthIncome = 0;
    _monthExpenses = 0;
    _weeklyExpenses = 0;
    _recurringExpenses = 0;
    _previousMonthExpenses = 0;

    final expenseDays = <DateTime>{};
    final sixMonthIndexByKey = <int, int>{};
    for (var i = 0; i < 6; i++) {
      final target = DateTime(now.year, now.month - (5 - i));
      sixMonthIndexByKey[target.year * 100 + target.month] = i;
    }

    for (final item in _transactions) {
      final isIncome = item.type == TransactionType.income;
      final isExpense = item.type == TransactionType.expense;

      if (isIncome) {
        _totalIncome += item.amount;
      } else if (isExpense) {
        _totalExpenses += item.amount;
      }

      final isCurrentMonth =
          item.date.year == now.year && item.date.month == now.month;
      if (isCurrentMonth) {
        _currentMonthTransactions.add(item);
        if (isIncome) {
          _monthIncome += item.amount;
        } else if (isExpense) {
          _monthExpenses += item.amount;
          _spendingByCategory[item.categoryKey] =
              (_spendingByCategory[item.categoryKey] ?? 0) + item.amount;
          if (item.isRecurring) _recurringExpenses += item.amount;
        }
      }

      if (isExpense &&
          item.date.year == previousMonth.year &&
          item.date.month == previousMonth.month) {
        _previousMonthExpenses += item.amount;
      }

      if (isExpense) {
        final day = DateTime(item.date.year, item.date.month, item.date.day);
        if (!day.isBefore(weekStart) && !day.isAfter(today)) {
          _weeklyExpenses += item.amount;
          expenseDays.add(day);
          final dayIndex = day.difference(weekStart).inDays;
          if (dayIndex >= 0 && dayIndex < 7) {
            _lastSevenDayExpenseTrend[dayIndex] += item.amount;
          }
        }

        final monthIndex =
            sixMonthIndexByKey[item.date.year * 100 + item.date.month];
        if (monthIndex != null) {
          _sixMonthExpenseTrend[monthIndex] += item.amount;
        }
      }
    }

    _currentMonthTransactions.sort((a, b) => b.date.compareTo(a.date));
    _noSpendDaysThisWeek = 7 - expenseDays.length;

    _totalBudget = 0;
    _activeBudgetCount = 0;
    for (final budget in _budgets) {
      _budgetByCategory[budget.categoryKey] = budget.limit;
      _totalBudget += budget.limit;
      if (budget.limit > 0) _activeBudgetCount++;
    }

    if (_spendingByCategory.isEmpty) {
      _largestExpenseCategory = null;
    } else {
      _largestExpenseCategory = _spendingByCategory.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
    }
  }
}
