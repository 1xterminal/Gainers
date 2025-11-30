class SleepGoal {
  final int targetMinutes;
  final DateTime createdAt;

  SleepGoal({
    required this.targetMinutes,
    required this.createdAt,
  });

  int get targetHours => targetMinutes ~/ 60;
  int get targetRemainingMinutes => targetMinutes % 60;
}
