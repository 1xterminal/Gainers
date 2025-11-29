class WeightLog {
  final String id;
  final String userId;
  final double weight;
  final double? skeletalMuscle;
  final double? bodyFat;
  final String? notes;
  final DateTime date;
  final DateTime createdAt;

  WeightLog({
    required this.id,
    required this.userId,
    required this.weight,
    this.skeletalMuscle,
    this.bodyFat,
    this.notes,
    required this.date,
    required this.createdAt,
  });

  factory WeightLog.fromJson(Map<String, dynamic> json) {
    return WeightLog(
      id: json['id'].toString(),
      userId: json['user_id'],
      weight: json['weight'].toDouble(),
      skeletalMuscle: json['skeletal_muscle'] != null ? (json['skeletal_muscle'] as num).toDouble() : null,
      bodyFat: json['body_fat'] != null ? (json['body_fat'] as num).toDouble() : null,
      notes: json['notes'],
      date: DateTime.parse(json['created_at']).toLocal(),
      createdAt: DateTime.parse(json['created_at']).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'weight': weight,
      'skeletal_muscle': skeletalMuscle,
      'body_fat': bodyFat,
      'notes': notes,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }
}