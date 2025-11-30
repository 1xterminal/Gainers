import 'package:supabase_flutter/supabase_flutter.dart';
import 'hydration_model.dart';

class HydrationRepository {
  final SupabaseClient _client;

  HydrationRepository(this._client);

  Future<List<HydrationLog>> getLogs(DateTime date) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final response = await _client
        .from('water_logs')
        .select()
        .eq('user_id', userId)
        .gte('created_at', startOfDay.toUtc().toIso8601String())
        .lt('created_at', endOfDay.toUtc().toIso8601String())
        .order('created_at', ascending: true);

    return (response as List).map((e) => HydrationLog.fromJson(e)).toList();
  }

  Future<void> addLog(HydrationLog log) async {
    // Note: log.toJson() includes 'id', but Supabase generates it.
    // However, HydrationLog model has 'id' as String? and toJson includes it if present?
    // Wait, HydrationLog.toJson() DOES NOT include 'id'. It includes user_id, amount_ml, created_at.
    // So this is fine.
    await _client.from('water_logs').insert(log.toJson());
  }

  Future<void> updateLog(HydrationLog log) async {
    if (log.id == null) return;
    // We need to exclude 'id' and 'user_id' from update usually, but toJson includes user_id.
    // Supabase ignores user_id update if it's the same, or we can just send amount_ml and created_at.
    // But log.toJson() returns all. It's fine.
    await _client.from('water_logs').update(log.toJson()).eq('id', log.id!);
  }

  Future<void> deleteLog(String id) async {
    await _client.from('water_logs').delete().eq('id', id);
  }

  Future<void> setDailyTarget(int target) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await _client
        .from('profiles')
        .update({'hydration_target': target})
        .eq('id', userId);
  }

  Future<int> getDailyTarget() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return 2000;

    try {
      final response = await _client
          .from('profiles')
          .select('hydration_target')
          .eq('id', userId)
          .single();
      return response['hydration_target'] as int? ?? 2000;
    } catch (e) {
      return 2000;
    }
  }
}
