void main() {
  // Test templates from AppConstants
  List<String> templates = [
    "Dear Babi your Account 1*****4345 has been debited with ETB3,000.00 .Service charge of  ETB10 and VAT(15%) of ETB1.50 with a total of ETB3011. Your Current Balance is ETB 14,016.34. Thank you for Banking with CBE! https://apps.cbe.com.et:100/?id=FT25344M3LMC61234345",
    "Dear Babi your Account 1****4345 has been credited with ETB 17000.00. Your Current Balance is ETB 17027.84. Thank you for Banking with CBE! https://apps.cbe.com.et:100/BranchReceipt/FT25343JTQ2D&61234345",
    "Dear Babi your Account 1*****4345 has been debited with ETB1,750.00 .Including Service charge and VAT(15%) with a total of ETB 1763.80. Your Current Balance is ETB 81.11. Thank you for Banking with CBE! https://apps.cbe.com.et:100/?id=FT25322FQMV061234345",
    "Dear Babi your Account 1*****4345 has been Credited with ETB 6,000.00 from Edom Getaneh, on 11/11/2025 at 06:27:52 with Ref No FT25315LT0PD Your Current Balance is ETB 7,702.41. Thank you for Banking with CBE! https://apps.cbe.com.et:100/?id=FT25315LT0PD61234345",
    "Dear Babi, You have transfered ETB 10,000.00 to Rediet Mesfin on 02/11/2025 at 15:40:42 from your account 1*****4345. Your account has been debited with a S.charge of ETB 2.00 and  15% VAT of ETB0.30, with a total of ETB10002.30. Your Current Balance is ETB 1,298.91. Thank you for Banking with CBE! https://apps.cbe.com.et:100/?id=FT253065G5TV61234345 For feedback click the link https://forms.gle/R1s9nkJ6qZVCxRVu9"
  ];

  // Regexes corresponding to the 5 SmsPattern entries I updated
  List<String> regexes = [
    // CBE Debit with Account
    r"Account\s+(?<account>\d+\*{3,}\d+).*?debited\s+with\s+ETB\s?(?<amount>[\d,.]+).*?Balance\s+is\s+ETB\s?(?<balance>[\d,.]+).*?((id=|BranchReceipt/)(?<reference>FT\w+))",
    // CBE Credit with Account
    r"Account\s+(?<account>\d+\*{3,}\d+).*?credited\s+with\s+ETB\s?(?<amount>[\d,.]+).*?Balance\s+is\s+ETB\s?(?<balance>[\d,.]+).*?((id=|BranchReceipt/)(?<reference>FT\w+))",
    // CBE Debit with Account (duplicate case for 3rd template)
    r"Account\s+(?<account>\d+\*{3,}\d+).*?debited\s+with\s+ETB\s?(?<amount>[\d,.]+).*?Balance\s+is\s+ETB\s?(?<balance>[\d,.]+).*?((id=|BranchReceipt/)(?<reference>FT\w+))",
    // CBE Credit with Account (duplicate case for 4th template)
    r"Account\s+(?<account>\d+\*{3,}\d+).*?credited\s+with\s+ETB\s?(?<amount>[\d,.]+).*?Balance\s+is\s+ETB\s?(?<balance>[\d,.]+).*?((id=|BranchReceipt/)(?<reference>FT\w+))",
    // CBE Transfer Debit
    r"transfered\s+ETB\s?(?<amount>[\d,.]+)\s+to.*Balance\s+is\s+ETB\s?(?<balance>[\d,.]+).*?((id=|BranchReceipt/)(?<reference>FT\w+))"
  ];

  for (int i = 0; i < templates.length; i++) {
    String msg = templates[i];
    // Try to match against ANY of our regexes, just like the parser would
    bool matched = false;
    for (String rx in regexes) {
      RegExp regExp =
          RegExp(rx, caseSensitive: false, multiLine: true, dotAll: true);
      RegExpMatch? match = regExp.firstMatch(msg);
      if (match != null) {
        print("debug: Template $i MATCHED!");
        print("debug:   Reference: ${match.namedGroup('reference')}");
        print(
            "dubg:   Ref Group exists: ${match.groupNames.contains('reference')}");
        matched = true;
        break;
      }
    }
    if (!matched) {
      print("debug: Template $i FAILED to match any regex.");
    }
    print("debug: ---");
  }
}
