import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/food_entry.dart';

class FoodEntriesNotifier extends StateNotifier<List<FoodEntry>> {
  FoodEntriesNotifier() : super(_seed);

  static final List<FoodEntry> _seed = [
    FoodEntry(
      id: '1',
      date: DateTime(2026, 7, 1),
      morningMeal: 'Idli, Sambar',
      morningPrice: 50,
      afternoonMeal: 'Meals, Rasam',
      afternoonPrice: 100,
      nightMeal: 'Chapati, Dal',
      nightPrice: 70,
      notes: 'Normal food',
    ),
    FoodEntry(
      id: '2',
      date: DateTime(2026, 6, 30),
      morningMeal: 'Dosa, Chutney',
      morningPrice: 40,
      afternoonMeal: 'Biryani, Raita',
      afternoonPrice: 120,
      nightMeal: 'Rice, Curd',
      nightPrice: 60,
    ),
    FoodEntry(
      id: '3',
      date: DateTime(2026, 6, 29),
      morningMeal: 'Poha',
      morningPrice: 30,
      afternoonMeal: 'Veg Pulao, Curd',
      afternoonPrice: 100,
      nightMeal: 'Paratha, Sabji',
      nightPrice: 60,
    ),
  ];

  void add(FoodEntry entry) {
    state = [entry, ...state]..sort((a, b) => b.date.compareTo(a.date));
  }

  void update(FoodEntry entry) {
    state = [
      for (final e in state)
        if (e.id == entry.id) entry else e,
    ]..sort((a, b) => b.date.compareTo(a.date));
  }

  void remove(String id) {
    state = state.where((e) => e.id != id).toList();
  }
}

final foodEntriesProvider =
    StateNotifierProvider<FoodEntriesNotifier, List<FoodEntry>>(
      (ref) => FoodEntriesNotifier(),
    );

final grandTotalProvider = Provider<double>((ref) {
  final entries = ref.watch(foodEntriesProvider);
  return entries.fold<double>(0, (sum, e) => sum + e.total);
});
