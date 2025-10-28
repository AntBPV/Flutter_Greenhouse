import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static Future<void> initialize() async {
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseApiKey = dotenv.env['SUPABASE_API_KEY'];

    if (supabaseUrl == null || supabaseApiKey == null) {
      throw Exception('Missing Supabase credentials on the .env file');
    }

    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseApiKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}
