import '../services/hive_service.dart';

class ThemeBox {
  static const _keyIsDarkMode = 'isDarkMode';

  static Future<void> saveTheme(bool isDarkMode) async {
    final box = HiveService.themeBox;
    await box.put(_keyIsDarkMode, isDarkMode);
  }

  static bool loadTheme() {
    final box = HiveService.themeBox;
    return box.get(_keyIsDarkMode, defaultValue: false);
  }
}
