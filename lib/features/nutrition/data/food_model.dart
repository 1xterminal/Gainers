class FoodLog {
  final int? id;
  final String userId;
  final String foodName;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final String mealType; // 'breakfast', 'lunch', 'dinner', 'snack'
  final DateTime createdAt;

  FoodLog({
    this.id,
    required this.userId,
    required this.foodName,
    required this.calories,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    required this.mealType,
    required this.createdAt,
  });

  factory FoodLog.fromJson(Map<String, dynamic> json) {
    return FoodLog(
      id: json['id'] as int?,
      userId: json['user_id'] ?? '',
      foodName: json['food_name'] ?? '',
      calories: json['calories'] ?? 0,
      protein: json['protein_g'] ?? 0,
      carbs: json['carbs_g'] ?? 0,
      fat: json['fat_g'] ?? 0,
      mealType: json['meal_type'] ?? 'snack',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id' tidak dikirim saat insert
      'user_id': userId,
      'food_name': foodName,
      'calories': calories,
      'protein_g': protein,
      'carbs_g': carbs,
      'fat_g': fat,
      'meal_type': mealType,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
