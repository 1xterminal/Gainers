class Profile {
  final String id;
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final String? gender;
  final DateTime? dateOfBirth;
  final int? heightCm;
  final double? weightKg;
  final String? activityGoal;
  final String? unitPreference;
  final int? hydrationTarget;

  Profile({
    required this.id,
    this.username,
    this.displayName,
    this.avatarUrl,
    this.gender,
    this.dateOfBirth,
    this.heightCm,
    this.weightKg,
    this.activityGoal,
    this.unitPreference,
    this.hydrationTarget,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      username: json['username'],
      displayName: json['display_name'],
      avatarUrl: json['avatar_url'],
      gender: json['gender'],
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'])
          : null,
      heightCm: json['height_cm'],
      weightKg: json['weight_kg']?.toDouble(),
      activityGoal: json['activity_goal'],
      unitPreference: json['unit_preference'],
      hydrationTarget: json['hydration_target'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'gender': gender,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'activity_goal': activityGoal,
      'unit_preference': unitPreference,
      'hydration_target': hydrationTarget,
    };
  }

  Profile copyWith({
    String? id,
    String? username,
    String? displayName,
    String? avatarUrl,
    String? gender,
    DateTime? dateOfBirth,
    int? heightCm,
    double? weightKg,
    String? activityGoal,
    String? unitPreference,
    int? hydrationTarget,
  }) {
    return Profile(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      activityGoal: activityGoal ?? this.activityGoal,
      unitPreference: unitPreference ?? this.unitPreference,
      hydrationTarget: hydrationTarget ?? this.hydrationTarget,
    );
  }
}
