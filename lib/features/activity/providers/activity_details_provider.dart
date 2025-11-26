import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gainers/features/activity/data/models/step_data.dart';

//class to hold step data
class HealthState {
  final List<StepData> weeklyData;
  final int todaysSteps;
  final int lifetimeSteps;

  HealthState({
    required this.weeklyData,
    required this.todaysSteps,
    required this.lifetimeSteps,
  });
}

//notifier to handle fetch health data
class HealthNotifier extends AsyncNotifier<HealthState> {
  final Health _health = Health();

  @override
  Future<HealthState> build() async {
    return _fetchHealthData();
  }

  //method to fetch health data
  Future<HealthState> _fetchHealthData() async {
    //1. ask for permission
    var activityStatus = await Permission.activityRecognition.request();

    if (activityStatus.isPermanentlyDenied) {
      throw Exception('Activity Permission Is Permanently Denied!');
    }

    //2. define what data we want to fetch
    var types = [HealthDataType.STEPS];
    var permissions = [HealthDataAccess.READ];

    //3. check if we have permissions
    try {
      bool? hasPermissions = await _health.hasPermissions(
        types,
        permissions: permissions,
      );

      if (hasPermissions != true) {
        await _health.requestAuthorization(types, permissions: permissions);
      }
    } catch (e) {
      throw Exception('Failed to connect to Health Connect: $e');
    }

    List<StepData> weekSteps = [];
    DateTime now = DateTime.now();

    //4. fetch data for the last 7 days
    for (int i = 0; i < 7; i++) {
      DateTime date = now.subtract(Duration(days: i));
      DateTime startTime = DateTime(date.year, date.month, date.day, 0, 0, 0);
      DateTime endTime = DateTime(date.year, date.month, date.day, 23, 59, 59);

      try {
        int? steps = await _health.getTotalStepsInInterval(startTime, endTime);

        if (steps == null || steps == 0) {
          await _health.getHealthDataFromTypes(
            startTime: startTime,
            endTime: endTime,
            types: types,
          );
        }

        weekSteps.add(StepData(date, steps ?? 0));
      } catch (_) {
        weekSteps.add(StepData(date, 0));
      }
    }

    //5. reverse the list so the oldest data is first
    weekSteps = weekSteps.reversed.toList();

    //6. get lifetime steps
    DateTime lifetimeStart = DateTime(2000, 1, 1);
    int? lifetimeSteps = await _health.getTotalStepsInInterval(
      lifetimeStart,
      now,
    );

    //7. return the data
    return HealthState(
      weeklyData: weekSteps,
      todaysSteps: weekSteps.last.steps,
      lifetimeSteps: lifetimeSteps ?? 0,
    );
  }

  //function to reload data
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchHealthData());
  }
}

final healthProvider = AsyncNotifierProvider<HealthNotifier, HealthState>(() {
  return HealthNotifier();
});
