import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:totals/models/account.dart';

class AccountRepository {
  static const String key = "accounts";

  Future<List<Account>> getAccounts() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final List<String>? accountsList = prefs.getStringList(key);

    if (accountsList == null) return [];

    return accountsList
        .map((item) => Account.fromJson(jsonDecode(item)))
        .toList();
  }

  Future<void> saveAccount(Account account) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final List<String> existing = prefs.getStringList(key) ?? [];

    // Check if account exists, update if so
    bool found = false;
    for (int i = 0; i < existing.length; i++) {
      var acc = Account.fromJson(jsonDecode(existing[i]));
      if (acc.accountNumber == account.accountNumber &&
          acc.bank == account.bank) {
        existing[i] = jsonEncode(account.toJson());
        found = true;
        break;
      }
    }

    if (!found) {
      existing.add(jsonEncode(account.toJson()));
    }

    await prefs.setStringList(key, existing);
  }

  Future<void> saveAllAccounts(List<Account> accounts) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> encoded =
        accounts.map((a) => jsonEncode(a.toJson())).toList();
    await prefs.setStringList(key, encoded);
  }
}
