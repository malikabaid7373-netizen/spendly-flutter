import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/budget.dart';
import '../models/finance_transaction.dart';

class LocalDatabaseService {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final path = p.join(await getDatabasesPath(), 'spendly.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            amount REAL NOT NULL,
            type TEXT NOT NULL,
            category_key TEXT NOT NULL,
            date TEXT NOT NULL,
            note TEXT NOT NULL DEFAULT '',
            is_recurring INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE budgets(
            category_key TEXT PRIMARY KEY,
            limit_amount REAL NOT NULL
          )
        ''');
      },
    );
    return _database!;
  }

  Future<List<FinanceTransaction>> getTransactions() async {
    final db = await database;
    final rows = await db.query('transactions', orderBy: 'date DESC');
    return rows.map(FinanceTransaction.fromMap).toList();
  }

  Future<void> upsertTransaction(FinanceTransaction transaction) async {
    final db = await database;
    await db.insert('transactions', transaction.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Budget>> getBudgets() async {
    final db = await database;
    final rows = await db.query('budgets');
    return rows.map(Budget.fromMap).toList();
  }

  Future<void> upsertBudget(Budget budget) async {
    final db = await database;
    await db.insert('budgets', budget.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> seedFinanceData({
    required List<FinanceTransaction> transactions,
    required List<Budget> budgets,
    bool clearFirst = false,
  }) async {
    final db = await database;
    await db.transaction((txn) async {
      if (clearFirst) {
        await txn.delete('transactions');
        await txn.delete('budgets');
      }

      final batch = txn.batch();
      for (final transaction in transactions) {
        batch.insert(
          'transactions',
          transaction.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      for (final budget in budgets) {
        batch.insert(
          'budgets',
          budget.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  Future<void> clearFinanceData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('transactions');
      await txn.delete('budgets');
    });
  }
}
