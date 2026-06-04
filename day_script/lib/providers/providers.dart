import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/app_settings.dart';
import '../data/models/diary_entry.dart';
import '../data/models/tag.dart';
import '../data/repositories/entry_repository.dart';
import '../data/repositories/tag_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/services/database_service.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService.instance;
});

final entryRepositoryProvider = Provider<EntryRepository>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return EntryRepository(db.isar);
});

final tagRepositoryProvider = Provider<TagRepository>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return TagRepository(db.isar);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return SettingsRepository(db.isar);
});

final allEntriesProvider = FutureProvider.autoDispose<List<DiaryEntry>>((
  ref,
) async {
  final repo = ref.watch(entryRepositoryProvider);
  return repo.getAllEntries();
});

final entriesByDateProvider = FutureProvider.autoDispose
    .family<List<DiaryEntry>, DateTime>((ref, date) async {
      final repo = ref.watch(entryRepositoryProvider);
      return repo.getEntriesByDate(date);
    });

final entryByIdProvider = FutureProvider.autoDispose.family<DiaryEntry?, int>((
  ref,
  id,
) async {
  final repo = ref.watch(entryRepositoryProvider);
  return repo.getEntry(id);
});

final entryCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final repo = ref.watch(entryRepositoryProvider);
  return repo.getEntryCount();
});

final entriesGroupedByDateProvider =
    FutureProvider.autoDispose<Map<DateTime, List<DiaryEntry>>>((ref) async {
      final repo = ref.watch(entryRepositoryProvider);
      return repo.getEntriesGroupedByDate();
    });

final databaseSizeProvider = FutureProvider.autoDispose<int>((ref) async {
  final repo = ref.watch(entryRepositoryProvider);
  return repo.getDatabaseSize();
});

final allTagsProvider = FutureProvider.autoDispose<List<Tag>>((ref) async {
  final repo = ref.watch(tagRepositoryProvider);
  return repo.getAllTags();
});

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final repo = ref.watch(settingsRepositoryProvider);
    return repo.getSettings();
  }

  Future<void> setThemeMode(int mode) async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.setThemeMode(mode);
    ref.invalidateSelf();
  }

  Future<void> setAccentColor(String hex) async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.setAccentColor(hex);
    ref.invalidateSelf();
  }

  Future<void> setFontSizeScale(double scale) async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.setFontSizeScale(scale);
    ref.invalidateSelf();
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.setBiometricEnabled(enabled);
    ref.invalidateSelf();
  }

  Future<void> setPinEnabled(bool enabled) async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.setPinEnabled(enabled);
    ref.invalidateSelf();
  }

  Future<void> setPinHash(String? hash) async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.setPinHash(hash);
    ref.invalidateSelf();
  }

  Future<void> setLockAfterMinutes(int minutes) async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.setLockAfterMinutes(minutes);
    ref.invalidateSelf();
  }

  Future<void> setLastUnlockedAt(DateTime time) async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.setLastUnlockedAt(time);
    ref.invalidateSelf();
  }

  Future<void> setListDensity(int density) async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.setListDensity(density);
    ref.invalidateSelf();
  }

  Future<void> updateAll(AppSettings settings) async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.updateSettings(settings);
    ref.invalidateSelf();
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider.autoDispose<List<DiaryEntry>>((
  ref,
) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];
  final repo = ref.watch(entryRepositoryProvider);
  return repo.searchEntries(query);
});

class RecentSearchesNotifier extends StateNotifier<List<String>> {
  RecentSearchesNotifier() : super([]);

  void addSearch(String query) {
    if (query.isEmpty) return;
    state = [query, ...state.where((s) => s != query)].take(10).toList();
  }

  void removeSearch(String query) {
    state = state.where((s) => s != query).toList();
  }

  void clear() {
    state = [];
  }
}

final recentSearchesProvider =
    StateNotifierProvider<RecentSearchesNotifier, List<String>>(
      (ref) => RecentSearchesNotifier(),
    );

final isLockedProvider = StateProvider<bool>((ref) => false);

final needsAuthProvider = StateProvider<bool>((ref) => false);

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);
