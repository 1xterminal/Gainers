import 'package:shared_preferences/shared_preferences.dart';
import 'hydration_model.dart';

class HydrationRepository {
  static const String _storageKey = 'hydration_logs';
  static const String _dailyTargetKey = 'hydration_daily_target';

  Future<List<HydrationLog>> getLogs(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> logsJson = prefs.getStringList(_storageKey) ?? [];

    final allLogs = logsJson.map((log) => HydrationLog.fromJson(log)).toList();

    // Filter by date
    return allLogs.where((log) {
      return log.timestamp.year == date.year &&
          log.timestamp.month == date.month &&
          log.timestamp.day == date.day;
    }).toList();
  }

  Future<void> addLog(HydrationLog log) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> logsJson = prefs.getStringList(_storageKey) ?? [];

    logsJson.add(log.toJson());

    await prefs.setStringList(_storageKey, logsJson);
  }

  Future<void> updateLog(HydrationLog updatedLog) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> logsJson = prefs.getStringList(_storageKey) ?? [];

    final updatedLogsJson = logsJson.map((logJson) {
      final log = HydrationLog.fromJson(logJson);
      if (log.id == updatedLog.id) {
        return updatedLog.toJson();
      }
      return logJson;
    }).toList();

    await prefs.setStringList(_storageKey, updatedLogsJson);
  }

  Future<void> deleteLog(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> logsJson = prefs.getStringList(_storageKey) ?? [];

    final updatedLogsJson = logsJson.where((logJson) {
      final log = HydrationLog.fromJson(logJson);
      return log.id != id;
    }).toList();

    await prefs.setStringList(_storageKey, updatedLogsJson);
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
