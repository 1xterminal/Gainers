class HydrationLog {
  final String? id;
  final String userId;
  final int amountMl;
  final DateTime createdAt;

  HydrationLog({
    this.id,
    required this.userId,
    required this.amountMl,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'amount_ml': amountMl,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  factory HydrationLog.fromJson(Map<String, dynamic> json) {
    return HydrationLog(
      id: json['id']?.toString(),
      userId: json['user_id'] ?? '',
      amountMl: json['amount_ml'] ?? 0,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
    );
  }
}
