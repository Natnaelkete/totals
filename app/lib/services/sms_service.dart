import 'dart:convert';
import 'package:another_telephony/telephony.dart';
import 'package:totals/data/consts.dart';
import 'package:totals/utils/sms_utils.dart';
import 'package:totals/repositories/transaction_repository.dart';
import 'package:totals/repositories/account_repository.dart';
import 'package:totals/models/transaction.dart';
import 'package:totals/models/account.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Top-level function for background execution
@pragma('vm:entry-point')
onBackgroundMessage(SmsMessage message) async {
  // Defensive logging to trace execution
  try {
    print("BG: Handler started.");

    final String? address = message.address;
    print("BG: Address: '$address'");

    final String? body = message.body;
    if (body == null) {
      print("BG: Body is null. Exiting.");
      return;
    }

    print("BG: Checking if relevant...");
    if (SmsService.isRelevantMessage(address)) {
      print("BG: Message IS relevant. Processing...");
      await SmsService.processMessage(body);
      print("BG: Processing finished.");
    } else {
      print("BG: Message NOT relevant.");
    }
  } catch (e, stack) {
    print("BG: CRITICAL ERROR: $e");
    print(stack);
  }
}

class SmsService {
  final Telephony _telephony = Telephony.instance;
  final TransactionRepository _transactionRepo = TransactionRepository();
  final AccountRepository _accountRepo = AccountRepository();

  // Callback to notify UI to refresh
  Function()? onMessageReceived;

  Future<void> init() async {
    final bool? result = await _telephony.requestSmsPermissions;
    if (result != null && result) {
      _telephony.listenIncomingSms(
        onNewMessage: _handleForegroundMessage,
        onBackgroundMessage: onBackgroundMessage,
      );
    } else {
      print("SMS Permission denied");
    }
  }

  void _handleForegroundMessage(SmsMessage message) async {
    print("Foreground message from ${message.address}: ${message.body}");
    if (message.body == null) return;

    try {
      if (SmsService.isRelevantMessage(message.address)) {
        await SmsService.processMessage(message.body!);
        if (onMessageReceived != null) {
          onMessageReceived!();
        }
      }
    } catch (e) {
      print("Error processing foreground message: $e");
    }
  }

  /// Checks if the message address matches any of our known bank codes.
  static bool isRelevantMessage(String? address) {
    if (address == null) return false;
    for (var bank in AppConstants.banks) {
      for (var code in bank.codes) {
        print("Checking code: $code");
        if (address.contains(code)) {
          return true;
        }
      }
    }
    return false;
  }

  /// Static processing logic so it can be used by background handler too.
  /// Note: Background isolations mean we can't share the same Repository instances easily
  /// if they held state, but our Repositories are stateless wrappers around SharedPreferences,
  /// so creating new instances or using static logic is fine.
  static Future<void> processMessage(String messageBody) async {
    print("Processing message: $messageBody");
    var details = SmsUtils.extractCBETransactionDetails(messageBody);

    // 1. Check duplicate transaction
    // We need to read directly from SharedPreferences here because separate isolates don't share memory
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();

    // We can use our Repository logic if we instantiate it here or make it static helpers.
    // For simplicity, let's reuse the logic but we must be careful about concurrency.
    // Ideally valid code would lock, but SharedPreferences has basic locking.

    TransactionRepository txRepo = TransactionRepository();
    List<Transaction> existingTx = await txRepo.getTransactions();

    String? newRef = details['reference'];
    if (newRef != null && existingTx.any((t) => t.reference == newRef)) {
      print("Duplicate transaction skipped");
      return;
    }

    // 2. Update Account Balance
    if (details['accountNumber'] != null) {
      AccountRepository accRepo = AccountRepository();
      List<Account> accounts = await accRepo.getAccounts();

      String last4 = details['accountNumber'];
      // Find matching account (by last 4 digits)
      // Original logic assumes bankId 1 for CBE
      int index = accounts
          .indexWhere((a) => a.bank == 1 && a.accountNumber.endsWith(last4));

      if (index != -1) {
        Account old = accounts[index];
        // Update balance
        Account updated = Account(
            accountNumber: old.accountNumber,
            bank: old.bank,
            balance: details['currentBalance'] ?? old.balance,
            accountHolderName: old.accountHolderName,
            settledBalance: old.settledBalance,
            pendingCredit: old.pendingCredit);
        await accRepo.saveAccount(updated);
        print("Account balance updated for ${old.accountHolderName}");
      }
    }

    // 3. Save Transaction
    Transaction newTx = Transaction.fromJson(details);
    await txRepo.saveTransaction(newTx);
    print("New transaction saved: ${newTx.reference}");
  }
}
