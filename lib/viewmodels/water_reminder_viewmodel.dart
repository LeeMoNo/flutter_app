import 'dart:async';
import 'package:flutter/material.dart';

enum DrinkType { water, coffee, morning, other }

class DrinkRecord {
  final String name;
  final DateTime time;
  final int amountMl;
  final DrinkType type;

  const DrinkRecord({
    required this.name,
    required this.time,
    required this.amountMl,
    required this.type,
  });
}

class WaterReminderViewModel with ChangeNotifier {
  final List<DrinkRecord> _drinkRecords = [];
  Timer? _timer;
  bool _shouldShowReminder = false;

  int dailyGoal = 2000;

  int _consumedAmount = 0;

  int get consumedAmount => _consumedAmount;

  int get remainingAmount =>
      (_consumedAmount >= dailyGoal) ? 0 : dailyGoal - _consumedAmount;

  double get progress =>
      dailyGoal == 0 ? 0 : (_consumedAmount / dailyGoal).clamp(0.0, 1.0);

  int get progressPercent => (progress * 100).round();

  bool get shouldShowReminder => _shouldShowReminder;

  List<DrinkRecord> get todayRecords {
    final now = DateTime.now();
    return _drinkRecords
        .where(
          (record) =>
              record.time.year == now.year &&
              record.time.month == now.month &&
              record.time.day == now.day,
        )
        .toList()
      ..sort((a, b) => b.time.compareTo(a.time));
  }

  List<int> quickAmounts = const [150, 250, 350, 500];

  WaterReminderViewModel() {
    _seedDemoRecords();
    _startTimer();
  }

  void _seedDemoRecords() {
    final now = DateTime.now();
    _addRecordInternal(
      name: '白开水',
      time: DateTime(now.year, now.month, now.day, 14, 20),
      amountMl: 250,
      type: DrinkType.water,
    );
    _addRecordInternal(
      name: '黑咖啡',
      time: DateTime(now.year, now.month, now.day, 11, 5),
      amountMl: 150,
      type: DrinkType.coffee,
    );
    _addRecordInternal(
      name: '晨起补水',
      time: DateTime(now.year, now.month, now.day, 8, 30),
      amountMl: 400,
      type: DrinkType.morning,
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 3), (_) {
      if (_consumedAmount >= dailyGoal) return;
      _shouldShowReminder = true;
      notifyListeners();
    });
  }

  void clearReminderFlag() {
    _shouldShowReminder = false;
  }

  void recordDrink() {
    recordDrinkWithAmount(100);
  }

  void recordDrinkWithAmount(int amount, {String name = '白开水'}) {
    _addRecordInternal(
      name: name,
      time: DateTime.now(),
      amountMl: amount,
      type: DrinkType.water,
    );
    notifyListeners();
  }

  void _addRecordInternal({
    required String name,
    required DateTime time,
    required int amountMl,
    required DrinkType type,
  }) {
    _drinkRecords.add(
      DrinkRecord(
        name: name,
        time: time,
        amountMl: amountMl,
        type: type,
      ),
    );
    _consumedAmount += amountMl;
    if (_consumedAmount > dailyGoal) {
      _consumedAmount = dailyGoal;
    }
  }

  void cancelReminder() {}

  static IconData iconForType(DrinkType type) {
    switch (type) {
      case DrinkType.water:
        return Icons.water_drop_outlined;
      case DrinkType.coffee:
        return Icons.coffee_outlined;
      case DrinkType.morning:
        return Icons.wb_sunny_outlined;
      case DrinkType.other:
        return Icons.local_drink_outlined;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
