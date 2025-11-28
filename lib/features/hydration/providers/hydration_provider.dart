import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/hydration_model.dart';
import '../data/hydration_repository.dart';

final hydrationRepositoryProvider = Provider((ref) => HydrationRepository());

class HydrationNotifier extends AsyncNotifier<List<HydrationLog>> {
  late final HydrationRepository _repo;
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  @override
  Future<List<HydrationLog>> build() async {
    _repo = ref.read(hydrationRepositoryProvider);
    return _loadLogs();
  }

  Future<List<HydrationLog>> _loadLogs() async {
    return _repo.getLogs(_selectedDate);
  }

  Future<void> setDate(DateTime date) async {
    _selectedDate = date;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadLogs());
  }

  Future<void> addLog(int amount) async {
    final log = HydrationLog(
      id: const Uuid().v4(),
      amount: amount,
      timestamp: DateTime.now(),
    );

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.addLog(log);
      return _loadLogs();
    });
  }

  Future<void> updateLog(HydrationLog log) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.updateLog(log);
      return _loadLogs();
    });
  }

  Future<void> deleteLog(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.deleteLog(id);
      return _loadLogs();
    });
  }
}

final hydrationProvider =
    AsyncNotifierProvider<HydrationNotifier, List<HydrationLog>>(() {
      return HydrationNotifier();
    });

final dailyTargetProvider = AsyncNotifierProvider<DailyTargetNotifier, int>(() {
  return DailyTargetNotifier();
});

class DailyTargetNotifier extends AsyncNotifier<int> {
  late final HydrationRepository _repo;

  @override
  Future<int> build() async {
    _repo = ref.read(hydrationRepositoryProvider);
    return _repo.getDailyTarget();
  }

  Future<void> setTarget(int target) async {
    await _repo.setDailyTarget(target);
    state = AsyncValue.data(target);
  }
}
