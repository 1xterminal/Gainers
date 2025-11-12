import 'package:gainers/features/auth/domain/entities/user_entity.dart';
import 'package:gainers/features/auth/domain/repositories/auth_repository.dart';

class RegisterUser {
  final AuthRepository repository;

  RegisterUser(this.repository);

  Future<UserEntity> call(String email, String password, String username) {
    return repository.register(email, password, username);
  }
}