import 'package:isar/isar.dart';

part 'app_settings.g.dart';

@collection
class AppSettings {
  Id id = 1;

  late int themeMode;

  late String accentColorHex;

  late double fontSizeScale;

  late bool isBiometricEnabled;

  late bool isPinEnabled;

  String? pinHash;

  late int lockAfterMinutes;

  DateTime? lastUnlockedAt;

  late int listDensity;

  static AppSettings defaults() {
    return AppSettings()
      ..themeMode = 0
      ..accentColorHex = '#E8A838'
      ..fontSizeScale = 1.0
      ..isBiometricEnabled = false
      ..isPinEnabled = false
      ..pinHash = null
      ..lockAfterMinutes = 5
      ..lastUnlockedAt = null
      ..listDensity = 0;
  }
}
