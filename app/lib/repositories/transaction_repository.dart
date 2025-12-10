import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:totals/models/transaction.dart';

class TransactionRepository {
  static const String key = "transactions";

  Future<List<Transaction>> getTransactions() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs
        .reload(); // Reload to get latest data from other isolates/background
    final List<String>? transactionsList = prefs.getStringList(key);

    if (transactionsList == null) return [];

    return transactionsList
        .map((item) => Transaction.fromJson(jsonDecode(item)))
        .toList();
  }

  Future<void> saveTransaction(Transaction transaction) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();

    // Note: This is an expensive operation as we read all, append, and write all.
    // In a real database this would be an INSERT.
    final List<String> existing = prefs.getStringList(key) ?? [];
    existing.add(jsonEncode(transaction.toJson()));

    await prefs.setStringList(key, existing);
  }

  Future<void> saveAllTransactions(List<Transaction> transactions) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> encoded =
        transactions.map((t) => jsonEncode(t.toJson())).toList();
    await prefs.setStringList(key, encoded);
  }
}
