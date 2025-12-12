void main() {
  String msg =
      "Dear Babi your Account 1****4345 has been credited with ETB 17000.00. Your Current Balance is ETB 17027.84. Thank you for Banking with CBE! https://apps.cbe.com.et:100/BranchReceipt/FT25343JTQ2D&61234345";
  String rx =
      r"credited\s+with\s+ETB\s?(?<amount>[\d,.]+).*?Balance\s+is\s+ETB\s?(?<balance>[\d,.]+).*?((id=|BranchReceipt/)(?<reference>FT\w+))";

  RegExp regExp =
      RegExp(rx, caseSensitive: false, multiLine: true, dotAll: true);
  RegExpMatch? match = regExp.firstMatch(msg);

  if (match != null) {
    print("debug: MATCHED BranchReceipt!");
    print("debug: Ref: ${match.namedGroup('reference')}");
  } else {
    print("debug: FAILED BranchReceipt");
  }
}
