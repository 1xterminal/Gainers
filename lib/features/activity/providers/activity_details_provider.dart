import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gainers/features/activity/data/models/step_data.dart';

class HealthState {
  final List<StepData> weeklyData;
  final int todaysSteps;

  HealthState({required this.weeklyData, required this.todaysSteps});
}

class HealthNotifier extends AsyncNotifier<HealthState> {
  final Health _health = Health();

  @override
  Future<HealthState> build() async {
    return _fetchHealthData();
  }

  Future<HealthState> _fetchHealthData() async {
    var activityStatus = await Permission.activityRecognition.request();

    if (activityStatus.isPermanentlyDenied) {
      throw Exception('Activity Permission Is Permanently Denied!');
    }

    var types = [HealthDataType.STEPS];

    try {
      bool requested = await _health.requestAuthorization(types);
      print('$requested');
    } catch (e) {
      throw Exception('Health Connect Missing');
    }

    List<StepData> weekSteps = [];
    DateTime now = DateTime.now();

    for (int i = 0; i < 7; i++) {
      DateTime date = now.subtract(Duration(days: i));
      DateTime startTime = DateTime(date.year, date.month, date.day, 0, 0, 0);
      DateTime endTime = DateTime(date.year, date.month, date.day, 23, 59, 59);

      try {
        int? steps = await _health.getTotalStepsInInterval(startTime, endTime);
        weekSteps.add(StepData(date, steps ?? 0));
      } catch (e) {
        weekSteps.add(StepData(date, 0));
      }
    }

    weekSteps = weekSteps.reversed.toList();

    return HealthState(
      weeklyData: weekSteps,
      todaysSteps: weekSteps.last.steps,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchHealthData());
  }
}

final healthProvider = AsyncNotifierProvider<HealthNotifier, HealthState>(() {
  return HealthNotifier();
});
