import 'package:flutter/material.dart';
import '../services/counter_service.dart';

class CounterViewModel with ChangeNotifier {
  final CounterService _counterService;

  CounterViewModel(this._counterService) {
    _initialize();
  }

  int _count = 0;
  int get count => _count;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();
    try {
      _count = await _counterService.getInitialCount();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> increment() async {
    _isLoading = true;
    notifyListeners();
    try {
      _count++;
      await _counterService.saveCount(_count);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> decrement() async {
    _isLoading = true;
    notifyListeners();
    try {
      _count--;
      await _counterService.saveCount(_count);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reset() async {
    _isLoading = true;
    notifyListeners();
    try {
      _count = 0;
      await _counterService.saveCount(_count);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
