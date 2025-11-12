import 'package:gainers/features/auth/domain/entities/user_entity.dart';

class AuthState {
  final UserEntity? user;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    UserEntity? user,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}
