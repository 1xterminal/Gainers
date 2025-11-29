import 'dart:convert';

class HydrationLog {
  final String id;
  final int amount; // in ml
  final DateTime timestamp;

  HydrationLog({
    required this.id,
    required this.amount,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory HydrationLog.fromMap(Map<String, dynamic> map) {
    return HydrationLog(
      id: map['id'],
      amount: map['amount'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  String toJson() => json.encode(toMap());

  factory HydrationLog.fromJson(String source) =>
      HydrationLog.fromMap(json.decode(source));
}
