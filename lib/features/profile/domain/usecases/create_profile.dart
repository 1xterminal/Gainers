import 'package:gainers/features/profile/data/repositories/profile_repository.dart';
import 'package:gainers/features/profile/domain/entities/profile.dart';

class CreateProfile {
  final ProfileRepository repository;

  CreateProfile(this.repository);

  Future<void> call(Profile profile) async {
    await repository.updateProfile(profile);
  }
}
