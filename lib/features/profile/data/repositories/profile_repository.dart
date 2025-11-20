import 'package:gainers/features/profile/domain/entities/profile.dart';

abstract class ProfileRepository {
  Future<Profile?> getProfile(String userId);
  Future<void> createProfile(Profile profile);
  Future<bool> isProfileComplete(String userId);
}
