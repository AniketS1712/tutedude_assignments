import 'package:isar/isar.dart';

import '../models/diary_entry.dart';

class EntryRepository {
  final Isar _isar;

  EntryRepository(this._isar);

  Future<List<DiaryEntry>> getAllEntries() async {
    return _isar.diaryEntrys.where().sortByCreatedAtDesc().findAll();
  }

  Future<List<DiaryEntry>> getEntriesByDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return _isar.diaryEntrys
        .where()
        .filter()
        .createdAtBetween(start, end, includeUpper: false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<List<DiaryEntry>> getEntriesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    return _isar.diaryEntrys
        .where()
        .filter()
        .createdAtBetween(start, end)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<List<DiaryEntry>> getEntriesByMood(MoodEnum mood) async {
    return _isar.diaryEntrys
        .where()
        .filter()
        .moodEqualTo(mood)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<List<DiaryEntry>> getEntriesByTag(String tag) async {
    return _isar.diaryEntrys
        .where()
        .filter()
        .tagsElementEqualTo(tag)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<List<DiaryEntry>> getFavoriteEntries() async {
    return _isar.diaryEntrys
        .where()
        .filter()
        .isFavoriteEqualTo(true)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<List<DiaryEntry>> searchEntries(String query) async {
    if (query.isEmpty) return [];
    final lowerQuery = query.toLowerCase();
    return _isar.diaryEntrys
        .where()
        .filter()
        .titleContains(lowerQuery, caseSensitive: false)
        .or()
        .bodyPlainTextContains(lowerQuery, caseSensitive: false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<DiaryEntry?> getEntry(int id) async {
    return _isar.diaryEntrys.get(id);
  }

  Future<int> saveEntry(DiaryEntry entry) async {
    return _isar.writeTxn(() async {
      return _isar.diaryEntrys.put(entry);
    });
  }

  Future<bool> deleteEntry(int id) async {
    return _isar.writeTxn(() async {
      return _isar.diaryEntrys.delete(id);
    });
  }

  Future<int> getEntryCount() async {
    return _isar.diaryEntrys.count();
  }

  Stream<List<DiaryEntry>> watchAllEntries() {
    return _isar.diaryEntrys.where().sortByCreatedAtDesc().watch(
      fireImmediately: true,
    );
  }

  Future<Map<DateTime, List<DiaryEntry>>> getEntriesGroupedByDate() async {
    final entries = await getAllEntries();
    final Map<DateTime, List<DiaryEntry>> grouped = {};
    for (final entry in entries) {
      final dateKey = DateTime(
        entry.createdAt.year,
        entry.createdAt.month,
        entry.createdAt.day,
      );
      grouped.putIfAbsent(dateKey, () => []).add(entry);
    }
    return grouped;
  }

  Future<void> toggleFavorite(int id) async {
    final entry = await getEntry(id);
    if (entry != null) {
      entry.isFavorite = !entry.isFavorite;
      await saveEntry(entry);
    }
  }

  Future<int> getDatabaseSize() async {
    return _isar.getSize();
  }
}
