import 'package:gainers/features/profile/data/repositories/profile_repository.dart';
import 'package:gainers/features/profile/domain/entities/profile.dart';

class GetProfile {
  final ProfileRepository repository;

  GetProfile(this.repository);

  Future<Profile?> call(String userId) async {
    return await repository.getProfile(userId);
  }
}
