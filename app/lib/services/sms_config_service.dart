import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:totals/models/sms_pattern.dart';

class SmsConfigService {
  static const String _storageKey = "sms_patterns_config_v3";
  static final List<SmsPattern> _defaultPatterns = [
    // --- CBE Patterns ---
    // Try to capture account number if possible (1*****5345)
    // moved to top to ensure priority
    SmsPattern(
      bankId: 1,
      senderId: "CBE",
      regex:
          r"(?:Account|Acct)\s+(?<account>[\d\*]+).*?credited\s+with\s+ETB\s?(?<amount>[\d,.]+).*?Balance\s+is\s+ETB\s?(?<balance>[\d,.]+).*?((id=|BranchReceipt/)(?<reference>FT\w+))",
      type: "CREDIT",
      description: "CBE Credit with Account",
    ),
    SmsPattern(
      bankId: 1,
      senderId: "CBE",
      regex:
          r"(?:Account|Acct)\s+(?<account>[\d\*]+).*?debited\s+with\s+ETB\s?(?<amount>[\d,.]+).*?Balance\s+is\s+ETB\s?(?<balance>[\d,.]+).*?((id=|BranchReceipt/)(?<reference>FT\w+))",
      type: "DEBIT",
      description: "CBE Debit with Account",
    ),

    SmsPattern(
      bankId: 1,
      senderId: "CBE",
      // "credited with ETB 17000.00"
      regex:
          r"credited\s+with\s+ETB\s?(?<amount>[\d,.]+).*?Balance\s+is\s+ETB\s?(?<balance>[\d,.]+).*?((id=|BranchReceipt/)(?<reference>FT\w+))",
      type: "CREDIT",
      description: "CBE Credit Basic",
    ),
    SmsPattern(
      bankId: 1,
      senderId: "CBE",
      // "debited with ETB3,000.00"
      regex:
          r"debited\s+with\s+ETB\s?(?<amount>[\d,.]+).*?Balance\s+is\s+ETB\s?(?<balance>[\d,.]+).*?((id=|BranchReceipt/)(?<reference>FT\w+))",
      type: "DEBIT",
      description: "CBE Debit Basic",
    ),
    SmsPattern(
      bankId: 1,
      senderId: "CBE",
      regex:
          r"transfered\s+ETB\s?(?<amount>[\d,.]+)\s+to.*?from\s+your\s+account\s+(?<account>[\d\*]+).*?Balance\s+is\s+ETB\s?(?<balance>[\d,.]+).*?((id=|BranchReceipt/)(?<reference>FT\w+))",
      type: "DEBIT",
      description: "CBE Transfer Debit",
    ),
    SmsPattern(
        bankId: 1,
        senderId: "CBE",
        regex:
            r"(?:Account|Acct)\s+(?<account>[\d\*]+).*?has\s+been\s+debited\s+with\s+ETB\s?(?<amount>[\d,.]+).*?Current\s+Balance\s+is\s+ETB\s?(?<balance>[\d,.]+).*?(id=|BranchReceipt/)(?<reference>FT\w+)",
        type: "DEBIT",
        description: "CBE to own telebirr"),

    // --- Telebirr Patterns ---
    SmsPattern(
      bankId: 6,
      senderId: "telebirr",
      regex:
          r"transferred\s+ETB\s?(?<amount>[\d,.]+)\s+to\s+(?<receiver>[^(]+?)\s*\(.*?transaction\s+number\s+is\s+(?<reference>[A-Z0-9]+).*?balance\s+is\s+ETB\s?(?<balance>[\d,.]+)",
      type: "DEBIT",
      description: "Telebirr P2P Transfer",
    ),
    // 2. Transfer to Bank Account (Debit)
    SmsPattern(
      bankId: 6,
      senderId: "telebirr",
      regex:
          r"transferred\s+ETB\s?(?<amount>[\d,.]+).*?from\s+your\s+telebirr\s+account\s+(?<account>\d+)\s+to\s+(?<receiver>.+?)\s+account\s+number\s+(?<bankAccount>\d+).*?telebirr\s+transaction\s+number\s*is\s*(?<reference>[A-Z0-9]+).*?balance\s+is\s+ETB\s?(?<balance>[\d,.]+)",
      type: "DEBIT",
      description: "Telebirr to Bank Transfer",
    ),

    // 3. Merchant Goods Purchase (Debit)
    SmsPattern(
      bankId: 6,
      senderId: "telebirr",
      regex:
          r"paid\s+ETB\s?(?<amount>[\d,.]+)\s+for\s+goods\s+purchased\s+from\s+(?<receiver>.+?)\s+on.*?transaction\s+number\s+is\s+(?<reference>[A-Z0-9]+).*?balance\s+is\s+ETB\s?(?<balance>[\d,.]+)",
      type: "DEBIT",
      description: "Telebirr Merchant Purchase",
    ),

    // 4. Bill Payment / Airline (Debit)
    SmsPattern(
      bankId: 6,
      senderId: "telebirr",
      regex:
          r"paid\s+ETB\s?(?<amount>[\d,.]+)\s+to\s+(?<receiver>.+?)\s*(?:;|,\s*Bill).*?transaction\s+number\s+is\s+(?<reference>[A-Z0-9]+).*?balance\s+is\s+ETB\s?(?<balance>[\d,.]+)",
      type: "DEBIT",
      description: "Telebirr Bill Payment",
    ),

    // 5. P2P Received (Credit)
    SmsPattern(
      bankId: 6,
      senderId: "telebirr",
      regex: r"received\s+ETB\s?(?<amount>[\d,.]+)"
          r".*?\s+from\s+(?<sender>.+?)\s+on\s+"
          r"(?<date>\d{1,2}[\/]\d{1,2}[\/]\d{4}\s+\d{1,2}:\d{2}:\d{2})"
          r".*?transaction\s+number\s+is\s*(?<reference>[A-Z0-9]+)"
          r".*?balance\s+is\s+ETB\s?(?<balance>[\d,.]+)",
      type: "CREDIT",
      description: "Telebirr Money Received (P2P)",
    ),

    // 6. Bank Received (Credit) - Unique Structure
    SmsPattern(
      bankId: 6,
      senderId: "telebirr",
      regex:
          r"received\s+ETB\s?(?<amount>[\d,.]+)\s+by\s+transaction\s+number\s*(?<reference>[A-Z0-9]+).*?from\s+.*?\s+to\s+your\s+telebirr\s+account.*?balance\s+is\s+ETB\s?(?<balance>[\d,.]+)",
      type: "CREDIT",
      description: "Telebirr Received from Bank",
    ),
  ];
  String cleanSmsText(String text) {
    try {
      String jsonString = jsonEncode(text);
      String cleaned = jsonDecode(jsonString);
      cleaned = cleaned.replaceAll('\r', ' ');
      cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
      cleaned = cleaned.replaceAll(RegExp(r'\.\s*([A-Z])'), ' \$1');
      return cleaned.trim();
    } catch (e) {
      print("debug: JSON sanitization failed: $e");
      return text;
    }
  }

  Future<List<SmsPattern>> getPatterns() async {
    return _defaultPatterns;
  }

  Future<void> savePatterns(List<SmsPattern> patterns) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> encoded = patterns.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(_storageKey, encoded);
  }

  // Method to force fetch remote config (placeholder)
  Future<void> syncRemoteConfig() async {
    // await http.get(...)
    // await savePatterns(...)
  }
}
