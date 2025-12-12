import 'package:totals/utils/pattern_parser.dart';
import 'package:totals/models/sms_pattern.dart';

void main() {
  // Define Patterns (Manual copy from SmsConfigService state)

  var patternCreditAcc = SmsPattern(
    bankId: 1,
    senderId: "CBE",
    regex:
        r"(?:Account|Acct)\s+(?<account>[\d\*]+).*?credited\s+with\s+ETB\s?(?<amount>[\d,.]+).*?Balance\s+is\s+ETB\s?(?<balance>[\d,.]+).*?((id=|BranchReceipt/)(?<reference>FT\w+))",
    type: "CREDIT",
    description: "CBE Credit with Account",
  );

  var patternDebitAcc = SmsPattern(
    bankId: 1,
    senderId: "CBE",
    regex:
        r"(?:Account|Acct)\s+(?<account>[\d\*]+).*?debited\s+with\s+ETB\s?(?<amount>[\d,.]+).*?Balance\s+is\s+ETB\s?(?<balance>[\d,.]+).*?((id=|BranchReceipt/)(?<reference>FT\w+))",
    type: "DEBIT",
    description: "CBE Debit with Account",
  );

  // Basic patterns (without account capture currently) - intended for fallback, but user wants account capture
  var patternTransfer = SmsPattern(
    bankId: 1,
    senderId: "CBE",
    regex:
        r"transfered\s+ETB\s?(?<amount>[\d,.]+)\s+to.*?from\s+your\s+account\s+(?<account>[\d\*]+).*?Balance\s+is\s+ETB\s?(?<balance>[\d,.]+).*?((id=|BranchReceipt/)(?<reference>FT\w+))",
    type: "DEBIT",
    description: "CBE Transfer Debit",
  );

  List<SmsPattern> patterns = [
    patternCreditAcc,
    patternDebitAcc,
    patternTransfer
  ];

  // Test Messages from AppConstants
  List<String> messages = [
    // 1. Debit
    "Dear Babi your Account 1*****4345 has been debited with ETB3,000.00 .Service charge of  ETB10 and VAT(15%) of ETB1.50 with a total of ETB3011. Your Current Balance is ETB 14,016.34. Thank you for Banking with CBE! https://apps.cbe.com.et:100/?id=FT25344M3LMC61234345",
    // 2. Credit
    "Dear Babi your Account 1****4345 has been credited with ETB 17000.00. Your Current Balance is ETB 17027.84. Thank you for Banking with CBE! https://apps.cbe.com.et:100/BranchReceipt/FT25343JTQ2D&61234345",
    // 3. Debit (Service charge)
    "Dear Babi your Account 1*****4345 has been debited with ETB1,750.00 .Including Service charge and VAT(15%) with a total of ETB 1763.80. Your Current Balance is ETB 81.11. Thank you for Banking with CBE! https://apps.cbe.com.et:100/?id=FT25322FQMV061234345",
    // 4. Credit (from someone)
    "Dear Babi your Account 1*****4345 has been Credited with ETB 6,000.00 from Edom Getaneh, on 11/11/2025 at 06:27:52 with Ref No FT25315LT0PD Your Current Balance is ETB 7,702.41. Thank you for Banking with CBE! https://apps.cbe.com.et:100/?id=FT25315LT0PD61234345",
    // 5. Transfer
    "Dear Babi, You have transfered ETB 10,000.00 to Rediet Mesfin on 02/11/2025 at 15:40:42 from your account 1*****4345. Your account has been debited with a S.charge of ETB 2.00 and  15% VAT of ETB0.30, with a total of ETB10002.30. Your Current Balance is ETB 1,298.91. Thank you for Banking with CBE! https://apps.cbe.com.et:100/?id=FT253065G5TV61234345 For feedback click the link https://forms.gle/R1s9nkJ6qZVCxRVu9"
  ];

  print("debug: --- Starting Verification against 5 Constants ---");
  for (int i = 0; i < messages.length; i++) {
    print("debug: \nMsg $i:");
    var res =
        PatternParser.extractTransactionDetails(messages[i], "CBE", patterns);
    if (res != null) {
      print("debug:   [SUCCESS] Matched: ${res['type']}");
      print("debug:   Account: ${res['accountNumber']}");
      print("debug:   Amount: ${res['amount']}");
      if (res['accountNumber'] == null) {
        print("debug:   [FAILURE] Account is NULL");
      }
    } else {
      print("debug:   [FAILURE] No Match");
    }
  }
}
