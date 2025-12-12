import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:totals/models/failed_parse.dart';

class FailedParseRepository {
  static const String key = "failed_parses_v1";

  Future<List<FailedParse>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final List<String>? raw = prefs.getStringList(key);
    if (raw == null) return [];
    return raw.map((item) => FailedParse.fromJson(jsonDecode(item))).toList();
  }

  Future<void> add(FailedParse item) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final List<String> existing = prefs.getStringList(key) ?? [];
    existing.add(jsonEncode(item.toJson()));
    await prefs.setStringList(key, existing);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    await prefs.remove(key);
  }
}
