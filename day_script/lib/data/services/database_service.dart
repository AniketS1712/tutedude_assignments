import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/diary_entry.dart';
import '../models/tag.dart';
import '../models/app_settings.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService _instance = DatabaseService._();
  static DatabaseService get instance => _instance;

  Isar? _isar;

  Isar get isar {
    if (_isar == null) {
      throw StateError('Database not initialized. Call initialize() first.');
    }
    return _isar!;
  }

  bool get isInitialized => _isar != null;

  Future<void> initialize() async {
    if (_isar != null) return;

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [DiaryEntrySchema, tagSchema, AppSettingsSchema],
      directory: dir.path,
      name: 'dear_diary',
    );

    final settings = await _isar!.appSettings.get(1);
    if (settings == null) {
      await _isar!.writeTxn(() async {
        await _isar!.appSettings.put(AppSettings.defaults());
      });
    }
  }

  Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }
}
