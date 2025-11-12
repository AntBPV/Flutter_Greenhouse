import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String themeBoxName = 'themeBox';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(themeBoxName);
  }

  static Box get themeBox => Hive.box(themeBoxName);
}
