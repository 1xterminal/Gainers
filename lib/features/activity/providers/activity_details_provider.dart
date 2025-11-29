import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gainers/features/activity/data/models/step_data.dart';

//notifier to handle fetch health data
class HealthNotifier extends AsyncNotifier<StepData> {
  final Health _health = Health();
  DateTime _selectedDate = DateTime.now();

  @override
  Future<StepData> build() async {
    return _fetchHealthData();
  }

  //method to fetch health data
  Future<StepData> _fetchHealthData() async {
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

    //4. define time intervals
    DateTime date = _selectedDate;
    DateTime startTime = DateTime(date.year, date.month, date.day, 0, 0, 0);
    DateTime endTime = DateTime(date.year, date.month, date.day, 23, 59, 59);
    DateTime lifetimeStart = DateTime(2000, 1, 1);
    DateTime now = DateTime.now();

    //5. fetch data
    final results = await Future.wait([
      //todays steps
      _health.getTotalStepsInInterval(startTime, endTime),

      //lifetime steps
      _health.getTotalStepsInInterval(lifetimeStart, now),

      //highest steps
      _health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: lifetimeStart,
        endTime: now,
      ),
    ]);

    int todaysSteps = results[0] as int;
    int lifetimeSteps = results[1] as int;
    List<HealthDataPoint> healthData = results[2] as List<HealthDataPoint>;

    //6. get highest steps
    int highestSteps = 0;
    DateTime? highestStepsDate;
    try {
      healthData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: lifetimeStart,
        endTime: date,
      );
      Map<String, int> dailyStepsMap = {};

      for (var point in healthData) {
        String dayKey =
            '${point.dateFrom.year}-${point.dateFrom.month}-${point.dateFrom.day}';
        int steps = 0;

        if (point.value is NumericHealthValue) {
          steps = (point.value as NumericHealthValue).numericValue.toInt();
        }

        if (dailyStepsMap.containsKey(dayKey)) {
          dailyStepsMap[dayKey] = dailyStepsMap[dayKey]! + steps;
        } else {
          dailyStepsMap[dayKey] = steps;
        }
      }

      if (dailyStepsMap.isNotEmpty) {
        var maxEntry = dailyStepsMap.entries.reduce(
          (curr, next) => curr.value > next.value ? curr : next,
        );
        highestSteps = maxEntry.value;
        highestStepsDate = DateTime.parse(maxEntry.key);
      }
    } catch (e) {
      throw Exception('Failed to connect to Health Connect: $e');
    }

    //7. return the data
    return StepData(
      todaysSteps: todaysSteps,
      lifetimeSteps: lifetimeSteps,
      highestSteps: highestSteps,
      highestStepsDate: highestStepsDate,
    );
  }

  //function to reload data
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchHealthData());
  }

  Future<void> setDate(DateTime date) async {
    _selectedDate = date;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchHealthData());
  }

  DateTime get selectedDate => _selectedDate;
}

final healthProvider = AsyncNotifierProvider<HealthNotifier, StepData>(() {
  return HealthNotifier();
});
