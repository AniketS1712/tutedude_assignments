import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:journal_app/journal_model.dart';

List<JournalModel> journalEntries = [];

Future<void> saveEntries() async {
  final prefs = await SharedPreferences.getInstance();
  final String encodedData = jsonEncode(
    journalEntries.map((entry) => entry.toJson()).toList(),
  );
  await prefs.setString('journal_entries', encodedData);
}

Future<void> loadEntries() async {
  final prefs = await SharedPreferences.getInstance();
  final String? encodedData = prefs.getString('journal_entries');

  if (encodedData != null) {
    Iterable decodedData = jsonDecode(encodedData);
    journalEntries = decodedData
        .map((item) => JournalModel.fromJson(item))
        .toList();
  } else {
    journalEntries = [];
  }
}
