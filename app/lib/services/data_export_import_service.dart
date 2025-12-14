import 'dart:convert';
import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:totals/database/database_helper.dart';
import 'package:totals/models/account.dart';
import 'package:totals/models/transaction.dart';
import 'package:totals/models/failed_parse.dart';
import 'package:totals/models/sms_pattern.dart';
import 'package:totals/repositories/account_repository.dart';
import 'package:totals/repositories/transaction_repository.dart';
import 'package:totals/repositories/failed_parse_repository.dart';
import 'package:totals/services/sms_config_service.dart';

class DataExportImportService {
  final AccountRepository _accountRepo = AccountRepository();
  final TransactionRepository _transactionRepo = TransactionRepository();
  final FailedParseRepository _failedParseRepo = FailedParseRepository();
  final SmsConfigService _smsConfigService = SmsConfigService();

  /// Export all data to JSON
  Future<String> exportAllData() async {
    try {
      final accounts = await _accountRepo.getAccounts();
      final transactions = await _transactionRepo.getTransactions();
      final failedParses = await _failedParseRepo.getAll();
      final smsPatterns = await _smsConfigService.getPatterns();

      final exportData = {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'accounts': accounts.map((a) => a.toJson()).toList(),
        'transactions': transactions.map((t) => t.toJson()).toList(),
        'failedParses': failedParses.map((f) => f.toJson()).toList(),
        'smsPatterns': smsPatterns.map((p) => p.toJson()).toList(),
      };

      return jsonEncode(exportData);
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }

  /// Import all data from JSON
  Future<void> importAllData(String jsonData) async {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonData);

      // Validate version (for future compatibility)
      final version = data['version'] ?? '1.0';

      // Import accounts
      if (data['accounts'] != null) {
        final accountsList = (data['accounts'] as List)
            .map((json) => Account.fromJson(json as Map<String, dynamic>))
            .toList();
        await _accountRepo.saveAllAccounts(accountsList);
      }

      // Import transactions
      if (data['transactions'] != null) {
        final transactionsList = (data['transactions'] as List)
            .map((json) => Transaction.fromJson(json as Map<String, dynamic>))
            .toList();
        await _transactionRepo.saveAllTransactions(transactionsList);
      }

      // Import failed parses
      if (data['failedParses'] != null) {
        final db = await DatabaseHelper.instance.database;
        await db.delete('failed_parses'); // Clear existing
        final batch = db.batch();
        for (var json in data['failedParses'] as List) {
          final failedParse = FailedParse.fromJson(json as Map<String, dynamic>);
          batch.insert('failed_parses', {
            'address': failedParse.address,
            'body': failedParse.body,
            'reason': failedParse.reason,
            'timestamp': failedParse.timestamp,
          });
        }
        await batch.commit(noResult: true);
      }

      // Import SMS patterns
      if (data['smsPatterns'] != null) {
        final patternsList = (data['smsPatterns'] as List)
            .map((json) => SmsPattern.fromJson(json as Map<String, dynamic>))
            .toList();
        await _smsConfigService.savePatterns(patternsList);
      }
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }
}
