import 'package:gainers/features/profile/domain/entities/profile.dart';

abstract class ProfileRepository {
  Future<Profile?> getProfile(String userId);
  Future<void> updateProfile(Profile profile);
  Future<bool> isProfileComplete(String userId);
}
