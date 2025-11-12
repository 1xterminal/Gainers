import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gainers/core/errors/failure.dart';
import 'package:gainers/features/auth/domain/entities/user_entity.dart';
import 'package:gainers/features/auth/domain/repositories/auth_repository.dart';
import 'package:gainers/features/auth/data/models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient client;

  AuthRepositoryImpl(this.client);

  @override
  Future<UserEntity> login(String email, String password) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      final user = response.user;
      if (user == null) {
        throw const AuthFailure('Login failed: No user returned');
      }
      
      return UserModel(
        id: user.id,
        email: user.email ?? '',
      );
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw AuthFailure('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  // --- PENYESUAIAN ---
  // Menambahkan 'username'
  Future<UserEntity> register(String email, String password, String username) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        // Ini adalah bagian penting untuk trigger 'handle_new_user' kita
        data: {'username': username},
      );
      
      final user = response.user;
      if (user == null) {
        throw const AuthFailure('Registration failed: No user returned');
      }
      
      return UserModel(
        id: user.id,
        email: user.email ?? '',
      );
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw AuthFailure('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await client.auth.signOut();
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw AuthFailure('Logout failed: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final user = client.auth.currentUser;
      if (user == null) return null;
      
      return UserModel(
        id: user.id,
        email: user.email ?? '',
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw AuthFailure('Password reset failed: ${e.toString()}');
    }
  }
}