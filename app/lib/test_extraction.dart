import 'package:totals/utils/pattern_parser.dart';
import 'package:totals/models/sms_pattern.dart';

void main() {
  // 1. Define the Regex exactly as in SmsConfigService
  String regexCredit =
      r"(?:Account|Acct)\s+(?<account>[\d\*]+).*?credited\s+with\s+ETB\s?(?<amount>[\d,.]+).*?Balance\s+is\s+ETB\s?(?<balance>[\d,.]+).*?((id=|BranchReceipt/)(?<reference>FT\w+))";

  // 2. Define a sample message that we expect to match
  // Assuming the format is like: "Account 1000***1234 credited with ETB 500.00..."
  String message1 =
      "Account 1000***1234 credited with ETB 500.00. Balance is ETB 15,400.00. Ref id=FT12345678";

  // 3. Define the pattern object
  var pattern = SmsPattern(
    bankId: 1,
    senderId: "CBE",
    regex: regexCredit,
    type: "CREDIT",
    description: "Test Gen",
  );

  // 4. Test Extraction
  print("debug: Testing Message: '$message1'");
  print("debug: Using Regex: '$regexCredit'");

  var result =
      PatternParser.extractTransactionDetails(message1, "CBE", [pattern]);

  if (result != null) {
    print("debug: Match Found!");
    print("debug: Account: ${result['accountNumber']}");
    print("debug: Amount: ${result['amount']}");
    print("debug: Ref: ${result['reference']}");
  } else {
    print("debug: No Match Found.");
  }

  // Test Case 2: maybe spacing is different?
  String message2 =
      "Account 1000***5678 credited with ETB 100.00 Balance is ETB 100.00 id=FT9999";
  print("debug: \nTesting Message 2: '$message2'");
  var result2 =
      PatternParser.extractTransactionDetails(message2, "CBE", [pattern]);
  if (result2 != null) {
    print("debug: Match Found!");
    print("debug: Account: ${result2['accountNumber']}");
  } else {
    print("debug: No Match Found.");
  }
}
