import 'package:isar/isar.dart';

import '../models/app_settings.dart';

class SettingsRepository {
  final Isar _isar;

  SettingsRepository(this._isar);

  Future<AppSettings> getSettings() async {
    final settings = await _isar.appSettings.get(1);
    return settings ?? AppSettings.defaults();
  }

  Future<void> updateSettings(AppSettings settings) async {
    settings.id = 1;
    await _isar.writeTxn(() async {
      await _isar.appSettings.put(settings);
    });
  }

  Stream<AppSettings?> watchSettings() {
    return _isar.appSettings.watchObject(1, fireImmediately: true);
  }

  Future<void> setThemeMode(int mode) async {
    final settings = await getSettings();
    settings.themeMode = mode;
    await updateSettings(settings);
  }

  Future<void> setAccentColor(String hex) async {
    final settings = await getSettings();
    settings.accentColorHex = hex;
    await updateSettings(settings);
  }

  Future<void> setFontSizeScale(double scale) async {
    final settings = await getSettings();
    settings.fontSizeScale = scale;
    await updateSettings(settings);
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final settings = await getSettings();
    settings.isBiometricEnabled = enabled;
    await updateSettings(settings);
  }

  Future<void> setPinEnabled(bool enabled) async {
    final settings = await getSettings();
    settings.isPinEnabled = enabled;
    await updateSettings(settings);
  }

  Future<void> setPinHash(String? hash) async {
    final settings = await getSettings();
    settings.pinHash = hash;
    await updateSettings(settings);
  }

  Future<void> setLockAfterMinutes(int minutes) async {
    final settings = await getSettings();
    settings.lockAfterMinutes = minutes;
    await updateSettings(settings);
  }

  Future<void> setLastUnlockedAt(DateTime time) async {
    final settings = await getSettings();
    settings.lastUnlockedAt = time;
    await updateSettings(settings);
  }

  Future<void> setListDensity(int density) async {
    final settings = await getSettings();
    settings.listDensity = density;
    await updateSettings(settings);
  }
}
