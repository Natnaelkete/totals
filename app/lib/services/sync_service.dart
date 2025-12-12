import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:totals/models/transaction.dart';
import 'package:totals/repositories/transaction_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncService {
  final TransactionRepository _transactionRepo = TransactionRepository();
  static const String API_URL =
      'https://cniff-admin.vercel.app/api/transactions';

  Future<bool> syncTransactions() async {
    try {
      List<Transaction> transactions = await _transactionRepo.getTransactions();

      // Filter unsynced
      List<Transaction> unsynced =
          transactions.where((t) => t.status != 'SYNCED').toList();

      if (unsynced.isEmpty) {
        print("debug: No transactions to sync.");
        return true;
      }

      final response = await http.post(
        Uri.parse(API_URL),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'data': unsynced.map((t) => t.toJson()).toList()}),
      );

      if (response.statusCode == 201) {
        print("debug: Transactions synced successfully!");

        // Update local status
        // Note: This matches original logic which updates ALL to SYNCED if they match reference
        // This is slightly inefficient O(N^2) but matches original behavior

        List<Transaction> updatedList = transactions.map((t) {
          bool isUnsynced = unsynced.any((u) => u.reference == t.reference);
          if (isUnsynced) {
            // Return new instance with status SYNCED
            // Assuming Transaction is immutable, need copyWith or new constructor
            return Transaction(
                amount: t.amount,
                reference: t.reference,
                creditor: t.creditor,
                time: t.time,
                status: 'SYNCED',
                currentBalance: t.currentBalance,
                bankId: t.bankId,
                type: t.type,
                transactionLink: t.transactionLink,
                accountNumber: t.accountNumber);
          }
          return t;
        }).toList();

        await _transactionRepo.saveAllTransactions(updatedList);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_sync', DateTime.now().toString());

        return true;
      } else {
        print("debug: Failed to sync: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("debug: Sync failed: $e");
      return false;
    }
  }
}
