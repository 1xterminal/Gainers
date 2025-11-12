class FoodLog {
  final String id;
  final String foodName;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final String mealType;
  final DateTime createdAt;

  FoodLog({
    required this.id,
    required this.foodName,
    required this.calories,
    this.protein = 0, 
    this.carbs = 0,   
    this.fat = 0,     
    required this.mealType,
    required this.createdAt,
  });
}