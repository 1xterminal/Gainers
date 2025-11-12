import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gainers/main.dart';
import 'package:gainers/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:gainers/features/auth/domain/usecases/login_user.dart';
import 'package:gainers/features/auth/domain/usecases/register_user.dart';
import 'package:gainers/features/auth/domain/usecases/logout_user.dart';
import 'package:gainers/features/auth/domain/usecases/reset_password.dart';
import 'package:gainers/features/auth/providers/auth_state.dart';

// Repository provider
final authRepositoryProvider = Provider((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthRepositoryImpl(client);
});

// Use case providers
final loginUserProvider = Provider((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return LoginUser(repo);
});

final registerUserProvider = Provider((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return RegisterUser(repo);
});

final logoutUserProvider = Provider((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return LogoutUser(repo);
});

final resetPasswordProvider = Provider((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return ResetPassword(repo);
});

// Main auth state notifier provider
class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    return const AuthState();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await ref.read(loginUserProvider)(email, password);
      state = AsyncValue.data(AuthState(user: user, isAuthenticated: true));
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> register(String email, String password, String username) async {
    state = const AsyncValue.loading();
    try {
      final user = await ref.read(registerUserProvider)(email, password, username);
      state = AsyncValue.data(AuthState(user: user, isAuthenticated: true));
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await ref.read(logoutUserProvider)();
      state = const AsyncValue.data(AuthState());
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> resetPasswordRequest(String email) async {
    await ref.read(resetPasswordProvider)(email);
  }
}

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
