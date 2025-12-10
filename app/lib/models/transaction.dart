import 'dart:convert';

class Transaction {
  final String?
      amount; // Kept as String? to match some usage, but double is better
  final String? reference;
  final String? creditor;
  final String? time; // ISO string
  final String? status; // PENDING, CLEARED, SYNCED
  final String? currentBalance;
  final int? bankId;
  final String? type; // CREDIT or DEBIT
  final String? transactionLink;
  final String? accountNumber; // Last 4 digits

  Transaction({
    this.amount,
    this.reference,
    this.creditor,
    this.time,
    this.status,
    this.currentBalance,
    this.bankId,
    this.type,
    this.transactionLink,
    this.accountNumber,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      amount: json['amount']?.toString(),
      reference: json['reference'],
      creditor: json['creditor'],
      time: json['time'],
      status: json['status'],
      currentBalance: json['currentBalance']?.toString(),
      bankId: json['bankId'],
      type: json['type'],
      transactionLink: json['transactionLink'],
      accountNumber: json['accountNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'reference': reference,
      'creditor': creditor,
      'time': time,
      'status': status,
      'currentBalance': currentBalance,
      'bankId': bankId,
      'type': type,
      'transactionLink': transactionLink,
      'accountNumber': accountNumber,
    };
  }

  static String encode(List<Transaction> transactions) => json.encode(
        transactions.map<Map<String, dynamic>>((t) => t.toJson()).toList(),
      );

  static List<Transaction> decode(String transactions) =>
      (json.decode(transactions) as List<dynamic>)
          .map<Transaction>((item) => Transaction.fromJson(item))
          .toList();
}
