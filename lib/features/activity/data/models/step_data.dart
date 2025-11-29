class StepData {
  final int todaysSteps;
  final int lifetimeSteps;
  final int highestSteps;
  final DateTime? highestStepsDate;

  StepData({
    required this.todaysSteps,
    required this.lifetimeSteps,
    required this.highestSteps,
    this.highestStepsDate,
  });
}
