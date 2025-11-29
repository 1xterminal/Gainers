class SleepLog {
  final String id;
  final String userId;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final DateTime createdAt;

  SleepLog({
    required this.id,
    required this.userId,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.createdAt,
  });

  factory SleepLog.fromJson(Map<String, dynamic> json) {
    return SleepLog(
      id: json['id'].toString(),
      userId: json['user_id'],
      startTime: DateTime.parse(json['start_time']).toLocal(),
      endTime: DateTime.parse(json['end_time']).toLocal(),
      durationMinutes: json['duration_minutes'],
      createdAt: DateTime.parse(json['created_at']).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'start_time': startTime.toUtc().toIso8601String(),
      'end_time': endTime.toUtc().toIso8601String(),
      'duration_minutes': durationMinutes,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }
}
