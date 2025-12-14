/// Application constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'הלכות אבלות';
  static const String appVersion = '1.0.0';

  // Hive Box Names
  static const String favoritesBox = 'favorites';
  static const String settingsBox = 'settings';
  static const String readingPositionBox = 'reading_position';

  // Settings Keys
  static const String lastChapterKey = 'last_chapter';
  static const String lastScrollPositionKey = 'last_scroll_position';
  static const String fontSizeKey = 'font_size';

  // Font Size Settings
  static const double minFontSize = 12.0;
  static const double maxFontSize = 24.0;
  static const double defaultFontSize = 16.0;

  // Assets Paths
  static const String htmlAssetsPath = 'assets/html/';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);
}
