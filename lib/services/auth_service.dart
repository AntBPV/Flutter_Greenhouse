import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  // Obtener el usuario actual
  User? get currentUser => _supabase.auth.currentUser;

  // Verificar si hay una sesión activa
  bool get isAuthenticated => currentUser != null;

  // Registrar nuevo usuario
  Future<UserModel?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return UserModel(
          id: response.user!.id,
          email: response.user!.email!,
          createdAt: response.user!.createdAt != null
              ? DateTime.parse(response.user!.createdAt!)
              : null,
        );
      }
      return null;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Error on Sign Up: $e');
    }
  }

  // Iniciar sesión
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return UserModel(
          id: response.user!.id,
          email: response.user!.email!,
          createdAt: response.user!.createdAt != null
              ? DateTime.parse(response.user!.createdAt!)
              : null,
        );
      }
      return null;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Error on Login: $e');
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Error signing out: $e');
    }
  }

  // Obtener información del usuario actual
  UserModel? getCurrentUserModel() {
    final user = currentUser;
    if (user != null) {
      return UserModel(
        id: user.id,
        email: user.email!,
        createdAt: user.createdAt != null
            ? DateTime.parse(user.createdAt!)
            : null,
      );
    }
    return null;
  }
}
