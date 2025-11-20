import 'package:gainers/features/auth/domain/entities/user_entity.dart';

class AuthState {
  final UserEntity? user;
  final bool isAuthenticated;
  final bool? isProfileComplete;

  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isProfileComplete,
  });

  AuthState copyWith({
    UserEntity? user,
    bool? isAuthenticated,
    bool? isProfileComplete,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }
}

