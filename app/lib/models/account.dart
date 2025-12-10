import 'dart:convert';

class Account {
  final String accountNumber;
  final int bank; // Mapped to 'bank' in JSON
  final String balance; // Kept as String?
  final String accountHolderName;
  final double? settledBalance;
  final double? pendingCredit;

  Account({
    required this.accountNumber,
    required this.bank,
    required this.balance,
    required this.accountHolderName,
    this.settledBalance,
    this.pendingCredit,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      accountNumber: json['accountNumber'],
      bank: json['bank'],
      balance: json['balance'],
      accountHolderName: json['accountHolderName'],
      settledBalance: json['settledBalance']?.toDouble(),
      pendingCredit: json['pendingCredit']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountNumber': accountNumber,
      'bank': bank,
      'balance': balance,
      'accountHolderName': accountHolderName,
      'settledBalance': settledBalance,
      'pendingCredit': pendingCredit,
    };
  }

  static String encode(List<Account> accounts) => json.encode(
        accounts.map<Map<String, dynamic>>((a) => a.toJson()).toList(),
      );

  static List<Account> decode(String accounts) =>
      (json.decode(accounts) as List<dynamic>)
          .map<Account>((item) => Account.fromJson(item))
          .toList();
}
