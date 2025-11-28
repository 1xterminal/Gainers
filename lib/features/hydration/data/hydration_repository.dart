import 'package:shared_preferences/shared_preferences.dart';
import 'hydration_model.dart';

class HydrationRepository {
  static const String _storageKey = 'hydration_logs';
  static const String _dailyTargetKey = 'hydration_daily_target';

  List<HydrationLog>? _cachedLogs;

  Future<List<HydrationLog>> getLogs(DateTime date) async {
    if (_cachedLogs == null) {
      final prefs = await SharedPreferences.getInstance();
      final List<String> logsJson = prefs.getStringList(_storageKey) ?? [];
      _cachedLogs = logsJson.map((log) => HydrationLog.fromJson(log)).toList();
    }

    // Filter by date
    return _cachedLogs!.where((log) {
      return log.timestamp.year == date.year &&
          log.timestamp.month == date.month &&
          log.timestamp.day == date.day;
    }).toList();
  }

  Future<void> addLog(HydrationLog log) async {
    // Update cache
    if (_cachedLogs == null) {
      await getLogs(DateTime.now()); // Initialize cache if needed
    }
    _cachedLogs!.add(log);

    // Persist
    final prefs = await SharedPreferences.getInstance();
    final logsJson = _cachedLogs!.map((l) => l.toJson()).toList();
    await prefs.setStringList(_storageKey, logsJson);
  }

  Future<void> updateLog(HydrationLog updatedLog) async {
    if (_cachedLogs == null) {
      await getLogs(DateTime.now());
    }

    final index = _cachedLogs!.indexWhere((log) => log.id == updatedLog.id);
    if (index != -1) {
      _cachedLogs![index] = updatedLog;

      final prefs = await SharedPreferences.getInstance();
      final logsJson = _cachedLogs!.map((l) => l.toJson()).toList();
      await prefs.setStringList(_storageKey, logsJson);
    }
  }

  Future<void> deleteLog(String id) async {
    if (_cachedLogs == null) {
      await getLogs(DateTime.now());
    }

    _cachedLogs!.removeWhere((log) => log.id == id);

    final prefs = await SharedPreferences.getInstance();
    final logsJson = _cachedLogs!.map((l) => l.toJson()).toList();
    await prefs.setStringList(_storageKey, logsJson);
  }

  Future<void> setDailyTarget(int target) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dailyTargetKey, target);
  }

  Future<int> getDailyTarget() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_dailyTargetKey) ?? 2000;
  }
}
