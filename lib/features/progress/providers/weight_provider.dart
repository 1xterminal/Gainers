import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import "../data/weight_model.dart";
import "../repo/weight_repository.dart";

final weightRepositoryProvider = Provider((ref) {
  return WeightRepository(Supabase.instance.client);
});

class WeightProvider extends AsyncNotifier<List<WeightLog>> {
  late final WeightRepository _repo;
  DateTime _selectedDate = DateTime.now();

  @override
  Future<List<WeightLog>> build() async {
    _repo = ref.watch(weightRepositoryProvider);
    return _loadWeightLogs();
  }

  Future<List<WeightLog>> _loadWeightLogs() async {
    return _repo.getWeightLogs(_selectedDate);
  }

  Future<void> setDate(DateTime date) async {
    _selectedDate = date;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadWeightLogs());
  }

  DateTime get selectedDate => _selectedDate;

  Future<void> addLog(WeightLog log) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.addWeightLog(log);
      return _loadWeightLogs();
    });
  }

	Future<void> updateLog(WeightLog log) async {
		state = const AsyncValue.loading();
		state = await AsyncValue.guard(() async {
			await _repo.updateWeightLog(log);
			return _loadWeightLogs();
		});
	}

  Future<void> deleteLog(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.deleteWeightLog(id);
      return _loadWeightLogs();
    });
  }
}

final weightLogsProvider =
    AsyncNotifierProvider<WeightProvider, List<WeightLog>>(() {
  return WeightProvider();
});