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
    print("Requesting Activity Recognition Permission...");
    var activityStatus = await Permission.activityRecognition.request();
    print("Activity Recognition Status: $activityStatus");

    if (activityStatus.isPermanentlyDenied) {
      throw Exception('Activity Permission Is Permanently Denied!');
    }

    var types = [HealthDataType.STEPS];
    var permissions = [HealthDataAccess.READ];

    try {
      print("Checking if permissions are already granted...");
      bool? hasPermissions = await _health.hasPermissions(
        types,
        permissions: permissions,
      );
      print("Has Permissions: $hasPermissions");

      if (hasPermissions != true) {
        print("Requesting Health Connect Authorization...");
        bool requested = await _health.requestAuthorization(
          types,
          permissions: permissions,
        );
        print("Health Connect Authorization Granted: $requested");
      }
    } catch (e) {
      print("Error requesting authorization: $e");
      throw Exception('Failed to connect to Health Connect: $e');
    }

    List<StepData> weekSteps = [];
    DateTime now = DateTime.now();

    print("Fetching steps for the last 7 days...");
    for (int i = 0; i < 7; i++) {
      DateTime date = now.subtract(Duration(days: i));
      DateTime startTime = DateTime(date.year, date.month, date.day, 0, 0, 0);
      DateTime endTime = DateTime(date.year, date.month, date.day, 23, 59, 59);

      try {
        print("Fetching total steps for ${date.toString().split(' ')[0]}...");
        int? steps = await _health.getTotalStepsInInterval(startTime, endTime);
        print("Total Steps: $steps");

        if (steps == null || steps == 0) {
          print("Attempting to fetch raw data points for debugging...");
          List<HealthDataPoint> rawData = await _health.getHealthDataFromTypes(
            startTime: startTime,
            endTime: endTime,
            types: types,
          );
          print("Found ${rawData.length} raw data points.");
          for (var p in rawData) {
            print("Data Point: ${p.value} at ${p.dateFrom}");
          }
          // Optional: manually sum up if needed, but getTotalStepsInInterval should work.
        }

        weekSteps.add(StepData(date, steps ?? 0));
      } catch (e) {
        print("Error fetching steps for ${date.toString().split(' ')[0]}: $e");
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
