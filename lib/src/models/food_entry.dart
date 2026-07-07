import 'package:flutter/foundation.dart';

@immutable
class FoodEntry {
  const FoodEntry({
    required this.id,
    required this.date,
    required this.morningMeal,
    required this.morningPrice,
    required this.afternoonMeal,
    required this.afternoonPrice,
    required this.nightMeal,
    required this.nightPrice,
    this.notes = '',
  });

  final String id;
  final DateTime date;

  final String morningMeal;
  final double morningPrice;

  final String afternoonMeal;
  final double afternoonPrice;

  final String nightMeal;
  final double nightPrice;

  final String notes;

  double get total => morningPrice + afternoonPrice + nightPrice;

  
  factory FoodEntry.fromMap(Map<String, dynamic> map) {
    return FoodEntry(
      id: map['id'].toString(),
      date: DateTime.parse(map['date'] as String),
      morningMeal: (map['morning_meal'] ?? '') as String,
      morningPrice: (map['morning_price'] as num?)?.toDouble() ?? 0,
      afternoonMeal: (map['afternoon_meal'] ?? '') as String,
      afternoonPrice: (map['afternoon_price'] as num?)?.toDouble() ?? 0,
      nightMeal: (map['night_meal'] ?? '') as String,
      nightPrice: (map['night_price'] as num?)?.toDouble() ?? 0,
      notes: (map['notes'] ?? '') as String,
    );
  }

  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'morning_meal': morningMeal,
      'morning_price': morningPrice,
      'afternoon_meal': afternoonMeal,
      'afternoon_price': afternoonPrice,
      'night_meal': nightMeal,
      'night_price': nightPrice,
      'notes': notes,
    };
  }

  FoodEntry copyWith({
    String? id,
    DateTime? date,
    String? morningMeal,
    double? morningPrice,
    String? afternoonMeal,
    double? afternoonPrice,
    String? nightMeal,
    double? nightPrice,
    String? notes,
  }) {
    return FoodEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      morningMeal: morningMeal ?? this.morningMeal,
      morningPrice: morningPrice ?? this.morningPrice,
      afternoonMeal: afternoonMeal ?? this.afternoonMeal,
      afternoonPrice: afternoonPrice ?? this.afternoonPrice,
      nightMeal: nightMeal ?? this.nightMeal,
      nightPrice: nightPrice ?? this.nightPrice,
      notes: notes ?? this.notes,
    );
  }
}
