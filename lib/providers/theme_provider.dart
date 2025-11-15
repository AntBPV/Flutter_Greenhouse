import 'package:flutter/material.dart';
import '../data/theme_box.dart';

class ThemeProvider extends ChangeNotifier {
  late ThemeData _currentTheme;
  bool _isDarkMode = false;

  ThemeProvider() {
    // Se cargará más adelante con loadThemeFromHive()
    _currentTheme = _lightTheme;
  }

  ThemeData get theme => _currentTheme;
  bool get isDarkMode => _isDarkMode;

  static final ThemeData _lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
    brightness: Brightness.light,
    useMaterial3: true,
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        shape: MaterialStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
    ),
  );

  static final ThemeData _darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.amber,
      brightness: Brightness.dark,
    ),
    brightness: Brightness.dark,
    useMaterial3: true,
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        shape: MaterialStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
    ),
  );

  /// Cargar el tema desde Hive al iniciar
  Future<void> loadThemeFromHive() async {
    _isDarkMode = ThemeBox.loadTheme();
    _currentTheme = _isDarkMode ? _darkTheme : _lightTheme;
    notifyListeners();
  }

  /// Cambiar el tema y guardar en Hive
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _currentTheme = _isDarkMode ? _darkTheme : _lightTheme;
    ThemeBox.saveTheme(_isDarkMode);
    notifyListeners();
  }
}
