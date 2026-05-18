import 'dart:async';
import 'package:flutter/material.dart';

class WaterReminderViewModel with ChangeNotifier {
  final List<DateTime> _drinkHistory = [];
  Timer? _timer;
  
  // 每日目标喝水量
  final int dailyGoal = 800;
  
  // 已喝水量
  int _consumedAmount = 0;
  
  // 获取已喝水量
  int get consumedAmount => _consumedAmount;
  
  // 获取剩余喝水量
  int get remainingAmount => dailyGoal - _consumedAmount;

  List<DateTime> get drinkHistory => _drinkHistory;

  WaterReminderViewModel() {
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 3), (timer) {
      notifyListeners();
    });
  }

  // 记录喝水
  void recordDrink() {
    _drinkHistory.add(DateTime.now());
    _consumedAmount += 100;
    if (_consumedAmount > dailyGoal) {
      _consumedAmount = dailyGoal;
    }
    notifyListeners();
  }

  void cancelReminder() {
    // Handle cancel action if needed
    
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
