import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/sleep_model.dart';
import '../data/sleep_repository.dart';

final sleepRepositoryProvider = Provider((ref) {
  return SleepRepository(Supabase.instance.client);
});

class SleepNotifier extends AsyncNotifier<List<SleepLog>> {
  late SleepRepository _repo;
  DateTime _selectedDate = DateTime.now();

  @override
  Future<List<SleepLog>> build() async {
    _repo = ref.watch(sleepRepositoryProvider);
    return _loadLogs();
  }

  Future<List<SleepLog>> _loadLogs() async {
    return _repo.getSleepLogs(_selectedDate);
  }

  Future<void> setDate(DateTime date) async {
    _selectedDate = date;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadLogs());
  }

  DateTime get selectedDate => _selectedDate;

  Future<void> addLog(DateTime startTime, DateTime endTime) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final duration = endTime.difference(startTime).inMinutes;
    // Handle case where sleep crosses midnight (end time is before start time)
    // Actually, the UI should handle passing correct DateTime objects.
    // If endTime < startTime, it usually means next day.
    
    final log = SleepLog(
      id: '', // Supabase will generate
      userId: user.id,
      startTime: startTime,
      endTime: endTime,
      durationMinutes: duration,
      createdAt: DateTime.now(),
    );

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.addSleepLog(log);
      // Invalidate weekly provider to refresh chart
      ref.invalidate(weeklySleepLogsProvider); 
      return _loadLogs();
    });
  }
}

final weeklySleepLogsProvider = FutureProvider.family<List<SleepLog>, DateTime>((ref, date) async {
  final repo = ref.watch(sleepRepositoryProvider);
  // Get start and end of the week (e.g., Mon-Sun or just last 7 days)
  // Let's do last 7 days ending on 'date' for consistency chart
  // Or better: The week containing 'date'.
  // Let's stick to: 7 days ending on 'date' to show recent trend up to that day.
  final end = DateTime(date.year, date.month, date.day, 23, 59, 59);
  final start = end.subtract(const Duration(days: 6));
  
  return repo.getSleepLogsForRange(start, end);
});

final sleepProvider =
    AsyncNotifierProvider<SleepNotifier, List<SleepLog>>(() {
      return SleepNotifier();
    });
