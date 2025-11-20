import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gainers/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:gainers/features/profile/domain/entities/profile.dart';
// FIX: Removed double 'package' typo
import 'package:gainers/features/profile/domain/usecases/create_profile.dart';
import 'package:gainers/features/profile/domain/usecases/get_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Repository provider
final profileRepositoryProvider = Provider((ref) {
  final client = Supabase.instance.client;
  return ProfileRepositoryImpl(client);
});

// Use case providers
final isProfileCompleteProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, userId) async {
  final repo = ref.watch(profileRepositoryProvider);
  return await repo.isProfileComplete(userId);
});

final getProfileProvider =
    FutureProvider.autoDispose.family<Profile?, String>((ref, userId) async {
  final repo = ref.watch(profileRepositoryProvider);
  final getProfileUseCase = GetProfile(repo);
  return await getProfileUseCase(userId);
});

final createProfileProvider = Provider((ref) {
  final repo = ref.watch(profileRepositoryProvider);
  return CreateProfile(repo);
});