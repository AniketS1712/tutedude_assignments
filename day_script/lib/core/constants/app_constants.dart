class AppConstants {
  AppConstants._();

  static const String appName = 'Day Script';
  static const String appTagline = 'Your story starts here';

  static const Duration splashDuration = Duration(milliseconds: 2500);
  static const Duration fadeScaleDuration = Duration(milliseconds: 600);
  static const Duration slideDuration = Duration(milliseconds: 300);
  static const Duration circularRevealDuration = Duration(milliseconds: 500);
  static const Duration sheetSlideDuration = Duration(milliseconds: 400);
  static const Duration blurFadeDuration = Duration(milliseconds: 350);
  static const Duration searchDebounceDuration = Duration(milliseconds: 300);
  static const Duration autoSaveInterval = Duration(seconds: 30);

  static const double tabletBreakpoint = 600.0;
  static const double desktopBreakpoint = 900.0;

  static const double minTextScale = 0.85;
  static const double maxTextScale = 1.3;

  static const int pinLength = 6;
  static const int maxRecentSearches = 10;

  static const Map<String, String> moodColors = {
    'none': '#9E9E9E',
    'happy': '#4CAF50',
    'sad': '#2196F3',
    'angry': '#F44336',
    'tired': '#9C27B0',
    'excited': '#FF9800',
    'anxious': '#FF5722',
  };

  static const List<String> accentPresets = [
    '#E8A838',
    '#6C5CE7',
    '#00B894',
    '#E17055',
    '#0984E3',
    '#FD79A8',
    '#636E72',
  ];

  static const Map<String, double> fontSizes = {
    'small': 0.85,
    'medium': 1.0,
    'large': 1.15,
  };
}
