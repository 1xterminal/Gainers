import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gainers/features/auth/domain/entities/user_entity.dart';
import 'package:gainers/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:gainers/features/auth/domain/usecases/login_user.dart';
import 'package:gainers/features/auth/domain/usecases/register_user.dart';
import 'package:gainers/features/auth/domain/usecases/logout_user.dart';
import 'package:gainers/features/auth/domain/usecases/reset_password.dart';
import 'package:gainers/features/auth/providers/auth_state.dart';
import 'package:gainers/features/profile/providers/profile_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
// FIX: Hide AuthState from Supabase to avoid conflict with your custom AuthState
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

// Repository provider
final authRepositoryProvider = Provider((ref) {
  final client = Supabase.instance.client;
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
      final isProfileComplete = await ref.read(
        isProfileCompleteProvider(user.id).future,
      );
      state = AsyncValue.data(
        AuthState(
          user: user,
          isAuthenticated: true,
          isProfileComplete: isProfileComplete,
        ),
      );
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> register(String email, String password, String username) async {
    state = const AsyncValue.loading();
    try {
      final user = await ref.read(registerUserProvider)(
        email,
        password,
        username,
      );
      state = AsyncValue.data(
        AuthState(user: user, isAuthenticated: true, isProfileComplete: false),
      );
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

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      // 1. Trigger Google Sign-In
      // NOTE: We use the Web Client ID here to ensure we get an ID Token valid for Supabase
      const webClientId =
          '943457430288-a0ovdl1n0mtit73aigabl00gau886h6m.apps.googleusercontent.com';
      final googleSignIn = GoogleSignIn(serverClientId: webClientId);
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in flow
        state = const AsyncValue.data(AuthState());
        return;
      }

      // 2. Obtain the auth details from the request
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw 'No Access Token found.';
      }
      if (idToken == null) {
        throw 'No ID Token found.';
      }

      // 3. Sign in to Supabase with the tokens
      final response = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final user = response.user;
      if (user == null) throw 'Google Sign-In failed: No user returned';

      // 4. Check Profile Status
      final isProfileComplete = await ref.read(
        isProfileCompleteProvider(user.id).future,
      );

      // Map Supabase User to UserEntity
      // Assuming UserEntity has a constructor or factory that takes id and email
      // If UserEntity is just a wrapper, we might need to adapt this based on its definition.
      // Since I can't see UserEntity definition, I'll assume a basic mapping or use a helper if available.
      // Looking at other methods, they use `loginUserProvider` which returns `UserEntity`.
      // I should probably create a UserEntity manually here.

      final userEntity = UserEntity(id: user.id, email: user.email ?? '');

      state = AsyncValue.data(
        AuthState(
          user: userEntity,
          isAuthenticated: true,
          isProfileComplete: isProfileComplete,
        ),
      );
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
