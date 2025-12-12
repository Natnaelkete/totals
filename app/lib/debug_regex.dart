void main() {
  String message =
      "Dear Eyosiyas your Account 1****5345 has been debited with ETB3,000.00 .Service charge of  ETB10 and VAT(15%) of ETB1.50 with a total of ETB3011. Your Current Balance is ETB 14,016.34. Thank you for Banking with CB!";
  String regex =
      r"Account\s+(?<account>\d+\*{3,}\d+).*?debited\s+with\s+ETB\s?(?<amount>[\d,.]+).*?Balance\s+is\s+ETB\s?(?<balance>[\d,.]+)";

  RegExp regExp =
      RegExp(regex, caseSensitive: false, multiLine: true, dotAll: true);
  RegExpMatch? match = regExp.firstMatch(message);

  if (match != null) {
    print("debug: MATCH SUCCESS");
    print("debug: Account: ${match.namedGroup('account')}");
    print("debug: Amount: ${match.namedGroup('amount')}");
    print("debug: Balance: ${match.namedGroup('balance')}");
  } else {
    print("debug: MATCH FAILED");
  }
}
