import 'package:gainers/features/auth/domain/repositories/auth_repository.dart';

class ResetPassword {
  final AuthRepository repository;

  ResetPassword(this.repository);

  Future<void> call(String email) {
    return repository.resetPassword(email);
  }
}