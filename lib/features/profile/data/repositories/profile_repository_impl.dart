import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gainers/features/profile/data/repositories/profile_repository.dart';
import 'package:gainers/features/profile/domain/entities/profile.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseClient client;

  ProfileRepositoryImpl(this.client);

  @override
  Future<Profile?> getProfile(String userId) async {
    // .maybeSingle() is safer than .single() if the row might not exist
    final response = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle(); 

    if (response == null) {
      return null;
    }

    return Profile.fromJson(response);
  }

  @override
  Future<void> createProfile(Profile profile) async {
    // CHANGED: Use upsert instead of insert to handle existing rows safely
    await client.from('profiles').upsert(profile.toJson());
  }

  @override
  Future<bool> isProfileComplete(String userId) async {
    final response = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) {
      return false;
    }

    final profile = Profile.fromJson(response);
    
    // This logic matches your UI now
    return profile.displayName != null &&
        profile.gender != null &&
        profile.dateOfBirth != null &&
        profile.heightCm != null &&
        profile.weightKg != null &&
        profile.activityGoal != null;
  }
}