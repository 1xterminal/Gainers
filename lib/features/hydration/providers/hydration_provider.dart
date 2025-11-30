import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/hydration_model.dart';
import '../data/hydration_repository.dart';

final hydrationRepositoryProvider = Provider(
  (ref) => HydrationRepository(Supabase.instance.client),
);

final hydrationDateProvider = NotifierProvider<HydrationDateNotifier, DateTime>(
  HydrationDateNotifier.new,
);

class HydrationDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void setDate(DateTime date) => state = date;
}

class HydrationNotifier extends AsyncNotifier<List<HydrationLog>> {
  @override
  Future<List<HydrationLog>> build() async {
    final repo = ref.read(hydrationRepositoryProvider);
    final date = ref.watch(hydrationDateProvider);
    return repo.getLogs(date);
  }

  Future<void> addLog(int amount) async {
    final repo = ref.read(hydrationRepositoryProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    final log = HydrationLog(
      id: const Uuid().v4(),
      userId: userId,
      amountMl: amount,
      createdAt: DateTime.now(),
    );

    final previousState = state;
    // Optimistic update: add the log immediately to the UI
    if (state.hasValue) {
      final currentLogs = state.value!;
      state = AsyncValue.data([...currentLogs, log]);
    }

    try {
      await repo.addLog(log);
      // Similar to deleteLog, we can choose to reload or trust our local state.
      // For consistency and safety, let's reload silently.
      final date = ref.read(hydrationDateProvider);
      final freshLogs = await repo.getLogs(date);
      state = AsyncValue.data(freshLogs);
    } catch (e, st) {
      // Revert on error
      state = previousState;
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateLog(HydrationLog log) async {
    final repo = ref.read(hydrationRepositoryProvider);
    final previousState = state;
    // Optimistic update
    if (state.hasValue) {
      final currentLogs = state.value!;
      final index = currentLogs.indexWhere((l) => l.id == log.id);
      if (index != -1) {
        final updatedLogs = List<HydrationLog>.from(currentLogs);
        updatedLogs[index] = log;
        state = AsyncValue.data(updatedLogs);
      }
    }

    try {
      await repo.updateLog(log);
      // Reload silently to ensure consistency
      final date = ref.read(hydrationDateProvider);
      final freshLogs = await repo.getLogs(date);
      state = AsyncValue.data(freshLogs);
    } catch (e, st) {
      // Revert on error
      state = previousState;
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteLog(String id) async {
    final repo = ref.read(hydrationRepositoryProvider);
    final previousState = state;
    // Optimistic update: remove the log immediately from the UI
    if (state.hasValue) {
      final currentLogs = state.value!;
      state = AsyncValue.data(
        currentLogs.where((log) => log.id != id).toList(),
      );
    }

    try {
      await repo.deleteLog(id);
      // No need to reload logs if successful, as our local state is already correct
      // But to be safe and consistent with other methods, we can reload or just leave it.
      // Reloading ensures we are in sync with DB triggers etc if any.
      // For "smoothness", let's NOT reload immediately if we trust the local operation,
      // OR reload silently without setting state to loading.
      // _loadLogs() returns a Future<List>, we can update state with it.
      final date = ref.read(hydrationDateProvider);
      final freshLogs = await repo.getLogs(date);
      state = AsyncValue.data(freshLogs);
    } catch (e, st) {
      // Revert on error
      state = previousState;
      // You might want to show a snackbar here via a side-effect provider or callback
      state = AsyncValue.error(e, st);
    }
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
  @override
  Future<int> build() async {
    final repo = ref.read(hydrationRepositoryProvider);
    return repo.getDailyTarget();
  }

  Future<void> setTarget(int target) async {
    final repo = ref.read(hydrationRepositoryProvider);
    await repo.setDailyTarget(target);
    state = AsyncValue.data(target);
  }
}
