import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'config/supabase_config.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'services/sqlite_service.dart';
import 'providers/greenhouse_manager_provider.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await SupabaseConfig.initialize();

  final databaseService = SQLiteService();

  runApp(MyApp(databaseService: databaseService));
}

class MyApp extends StatelessWidget {
  final SQLiteService databaseService;

  const MyApp({super.key, required this.databaseService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => GreenhouseManagerProvider(databaseService),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              ThemeProvider()..loadThemeFromHive(), //TODO: Realizar HIVE
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Greenhouse_App',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.theme,
            initialRoute: '/',
            routes: {
              '/': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/home': (context) => const HomeScreen(),
            },
          );
        },
      ),
    );
  }
}
