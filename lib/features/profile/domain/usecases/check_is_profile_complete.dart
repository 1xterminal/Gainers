import 'package:gainers/features/profile/data/repositories/profile_repository.dart';

class CheckIsProfileComplete {
  final ProfileRepository repository;

  CheckIsProfileComplete(this.repository);

  Future<bool> call(String userId) async {
    return await repository.isProfileComplete(userId);
  }
}
