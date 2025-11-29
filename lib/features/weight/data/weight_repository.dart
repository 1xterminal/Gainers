import 'package:supabase_flutter/supabase_flutter.dart';
import 'weight_model.dart';
import '../../profile/domain/entities/profile.dart';

class WeightRepository {
  final SupabaseClient _client;

  WeightRepository(this._client);

  // 🎭 FULL DUMMY MODE: All data stored in memory
  static final List<WeightLog> _dummyLogs = [];
  static int _nextId = 1;

  Future<List<WeightLog>> getWeightLogs(DateTime date) async {
    // Return logs from memory for the selected date
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _dummyLogs.where((log) {
      return log.date.isAfter(startOfDay) && log.date.isBefore(endOfDay);
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addWeightLog(WeightLog log) async {
    // Create a new log with an ID
    final newLog = WeightLog(
      id: (_nextId++).toString(),
      userId: log.userId,
      weight: log.weight,
      skeletalMuscle: log.skeletalMuscle,
      bodyFat: log.bodyFat,
      notes: log.notes,
      date: log.date,
      createdAt: DateTime.now(),
    );

    // Add to memory
    _dummyLogs.add(newLog);

    // Optional: Still update profile weight in Supabase if you want that persisted
    try {
      await _client.from('profiles').upsert({
        'id': log.userId,
        'weight_kg': log.weight,
      });
    } catch (e) {
      // Ignore if profile update fails
      print('Could not update profile: $e');
    }
  }

  Future<WeightLog?> getLatestWeightLog() async {
    if (_dummyLogs.isEmpty) return null;

    // Sort by date and return the most recent
    final sorted = List<WeightLog>.from(_dummyLogs)
      ..sort((a, b) => b.date.compareTo(a.date));

    return sorted.first;
  }
}
