class WeightLog {
	final int id;
	final String userId;
	final double weight;
	final DateTime createdAt;

	WeightLog({
		required this.id,
		required this.userId,
		required this.weight,
		required this.createdAt,
	});

	factory WeightLog.fromJson(Map<String, dynamic> json) {
		return WeightLog(
			id: json['id'],
			userId: json['user_id'],
			weight: json['weight'],
			createdAt: DateTime.parse(json['created_at']),
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'id': id,
			'user_id': userId,
			'weight': weight,
			'created_at': createdAt.toIso8601String(),
		};
	}
}