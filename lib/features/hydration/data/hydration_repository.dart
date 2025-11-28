import 'package:shared_preferences/shared_preferences.dart';
import 'hydration_model.dart';

class HydrationRepository {
  static const String _storageKey = 'hydration_logs';

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

  Future<void> deleteLog(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> logsJson = prefs.getStringList(_storageKey) ?? [];

    final updatedLogs = logsJson.where((logStr) {
      final log = HydrationLog.fromJson(logStr);
      return log.id != id;
    }).toList();

    await prefs.setStringList(_storageKey, updatedLogs);
  }
}
