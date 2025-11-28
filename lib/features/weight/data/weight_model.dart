class WeightLog {
	final int? id;
	final String userId;
	final double weight_kg;
	final DateTime createdAt;

	WeightLog({
		this.id,
		required this.userId,
		required this.weight_kg,
		required this.createdAt,
	});

	factory WeightLog.fromJson(Map<String, dynamic> json) {
		return WeightLog(
			id: json['id'] as int?,
			userId: json['user_id'] ?? '',
			weight_kg: json['weight_kg'] ?? 0,
			createdAt: DateTime.parse(json['created_at']),
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'user_id': userId,
			'weight_kg': weight_kg,
			'created_at': createdAt.toIso8601String(),
		};
	}
}