import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:totals/models/account.dart';
import 'package:totals/models/transaction.dart';
import 'package:totals/models/summary_models.dart';
import 'package:totals/repositories/account_repository.dart';
import 'package:totals/repositories/transaction_repository.dart';

class TransactionProvider with ChangeNotifier {
  final TransactionRepository _transactionRepo = TransactionRepository();
  final AccountRepository _accountRepo = AccountRepository();

  List<Transaction> _transactions = [];
  List<Account> _accounts = [];

  // Summaries
  AllSummary? _summary;
  List<BankSummary> _bankSummaries = [];
  List<AccountSummary> _accountSummaries = [];

  bool _isLoading = false;
  String _searchKey = "";
  DateTime _selectedDate = DateTime.now();

  // Getters
  List<Transaction> _allTransactions = [];

  // Getters
  List<Transaction> get transactions => _transactions;
  List<Transaction> get allTransactions => _allTransactions;
  bool get isLoading => _isLoading;
  AllSummary? get summary => _summary;
  List<BankSummary> get bankSummaries => _bankSummaries;
  List<AccountSummary> get accountSummaries => _accountSummaries;
  DateTime get selectedDate => _selectedDate;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _accounts = await _accountRepo.getAccounts();
      _allTransactions = await _transactionRepo.getTransactions();

      _calculateSummaries(_allTransactions);
      _filterTransactions(_allTransactions);
    } catch (e) {
      print("debug: Error loading data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateSearchKey(String key) {
    _searchKey = key;
    loadData(); // Reload to re-filter
  }

  void updateDate(DateTime date) {
    _selectedDate = date;
    loadData();
  }

  void _calculateSummaries(List<Transaction> allTransactions) {
    // Group accounts by bank
    Map<int, List<Account>> groupedAccounts = {};
    for (var account in _accounts) {
      if (!groupedAccounts.containsKey(account.bank)) {
        groupedAccounts[account.bank] = [];
      }
      groupedAccounts[account.bank]!.add(account);
    }

    // Calculate Bank Summaries
    _bankSummaries = groupedAccounts.entries.map((entry) {
      int bankId = entry.key;
      List<Account> accounts = entry.value;

      // Filter transactions for this bank
      var bankTransactions =
          allTransactions.where((t) => t.bankId == bankId).toList();

      double totalDebit = 0.0;
      double totalCredit = 0.0;

      for (var t in bankTransactions) {
        double amount = t.amount;
        if (t.type == "DEBIT") {
          totalDebit += amount;
        } else if (t.type == "CREDIT") {
          totalCredit += amount;
        }
      }

      double settledBalance =
          accounts.fold(0.0, (sum, a) => sum + (a.settledBalance ?? 0.0));
      double pendingCredit =
          accounts.fold(0.0, (sum, a) => sum + (a.pendingCredit ?? 0.0));
      double totalBalance = accounts.fold(0.0, (sum, a) => sum + a.balance);

      return BankSummary(
        bankId: bankId,
        totalCredit: totalCredit,
        totalDebit: totalDebit,
        settledBalance: settledBalance,
        pendingCredit: pendingCredit,
        totalBalance: totalBalance,
        accountCount: accounts.length,
      );
    }).toList();

    // Calculate Account Summaries
    _accountSummaries = _accounts.map((account) {
      // Logic for specific account transactions
      // Note: original logic had a specific condition for bankId == 1 handling substrings
      var accountTransactions = allTransactions.where((t) {
        bool bankMatch = t.bankId == account.bank;
        if (!bankMatch) return false;

        if (account.bank == 1 &&
            t.accountNumber != null &&
            account.accountNumber.length >= 4) {
          // CBE check: last 4 digits
          return t.accountNumber ==
              account.accountNumber.substring(account.accountNumber.length - 4);
        } else {
          return t.accountNumber == account.accountNumber;
        }
      }).toList();

      // Fallback: If this is the ONLY account for this bank, also include transactions with NULL account number
      // This handles legacy data or parsing failures where account wasn't captured.
      var bankAccounts =
          _accounts.where((a) => a.bank == account.bank).toList();
      if (bankAccounts.length == 1 && bankAccounts.first == account) {
        var orphanedTransactions = allTransactions
            .where((t) =>
                t.bankId == account.bank &&
                (t.accountNumber == null || t.accountNumber!.isEmpty))
            .toList();
        accountTransactions.addAll(orphanedTransactions);
      }

      double totalDebit = 0.0;
      double totalCredit = 0.0;
      for (var t in accountTransactions) {
        double amount = t.amount;
        if (t.type == "DEBIT") totalDebit += amount;
        if (t.type == "CREDIT") totalCredit += amount;
      }

      return AccountSummary(
        bankId: account.bank,
        accountNumber: account.accountNumber,
        accountHolderName: account.accountHolderName,
        totalTransactions: accountTransactions.length.toDouble(),
        totalCredit: totalCredit,
        totalDebit: totalDebit,
        settledBalance: account.settledBalance ?? 0.0,
        balance: account.balance,
        pendingCredit: account.pendingCredit ?? 0.0,
      );
    }).toList();

    // Calculate AllSummary
    double grandTotalCredit =
        _bankSummaries.fold(0.0, (sum, b) => sum + b.totalCredit);
    double grandTotalDebit =
        _bankSummaries.fold(0.0, (sum, b) => sum + b.totalDebit);
    double grandTotalBalance =
        _bankSummaries.fold(0.0, (sum, b) => sum + b.totalBalance);

    _summary = AllSummary(
      totalCredit: grandTotalCredit,
      totalDebit: grandTotalDebit,
      banks: _accounts
          .length, // Original logic passed account length to banks? weird, but sticking to logic
      accounts: _accounts.length,
      totalBalance: grandTotalBalance,
    );
  }

  void _filterTransactions(List<Transaction> allTransactions) {
    // Filter by date and search key
    String dateStr =
        DateFormat('dd MMM yyyy').format(_selectedDate).toUpperCase();

    _transactions = allTransactions.where((t) {
      if (t.time == null) return false;
      bool dateMatch = t.time!.toUpperCase().contains(dateStr);
      if (!dateMatch) return false;

      if (_searchKey.isEmpty) return true;

      return (t.creditor?.toLowerCase().contains(_searchKey.toLowerCase()) ??
              false) ||
          (t.reference?.toLowerCase().contains(_searchKey.toLowerCase()) ??
              false);
    }).toList();
  }

  // Method to handle new incoming SMS transaction
  Future<void> addTransaction(Transaction t) async {
    await _transactionRepo.saveTransaction(t);
    // Update account balance if match found
    // This logic was in onBackgroundMessage, we should probably centralize it here or in a Service
    // For now, simpler to just reload everything
    await loadData();
  }
}
