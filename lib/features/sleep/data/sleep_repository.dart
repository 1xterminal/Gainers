import 'package:supabase_flutter/supabase_flutter.dart';
import 'sleep_model.dart';

class SleepRepository {
  final SupabaseClient _client;

  SleepRepository(this._client);

  Future<List<SleepLog>> getSleepLogs(DateTime date) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    // Filter by start_time being on the selected date (in Local time terms)
    // We want logs where start_time (Local) is within [startOfDay, endOfDay)
    // So we convert startOfDay (Local) to UTC, and endOfDay (Local) to UTC.
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final response = await _client
        .from('sleep_logs')
        .select()
        .eq('user_id', userId)
        .gte('start_time', startOfDay.toUtc().toIso8601String())
        .lt('start_time', endOfDay.toUtc().toIso8601String())
        .order('start_time', ascending: false);

    return (response as List).map((e) => SleepLog.fromJson(e)).toList();
  }

  Future<List<SleepLog>> getSleepLogsForRange(DateTime start, DateTime end) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('sleep_logs')
        .select()
        .eq('user_id', userId)
        .gte('start_time', start.toUtc().toIso8601String())
        .lte('start_time', end.toUtc().toIso8601String())
        .order('start_time', ascending: true);

    return (response as List).map((e) => SleepLog.fromJson(e)).toList();
  }

  Future<void> addSleepLog(SleepLog log) async {
    await _client.from('sleep_logs').insert(log.toJson());
  }
  
  // Optional: Get latest sleep log for dashboard
  Future<SleepLog?> getLatestSleepLog() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _client
        .from('sleep_logs')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return SleepLog.fromJson(response);
  }
}
