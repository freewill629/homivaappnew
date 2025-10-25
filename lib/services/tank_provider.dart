import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import 'db_service.dart';

class TankProvider extends ChangeNotifier {
  TankProvider({required DbService db}) : _db = db;

  DbService _db;
  StreamSubscription<DatabaseEvent>? _subscription;

  double? _waterLevel;
  bool? _isOn;
  bool _isLoading = false;
  String? _error;

  double? get waterLevel => _waterLevel;
  bool? get isOn => _isOn;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void attachDb(DbService db) {
    _db = db;
  }

  Future<void> startListening() async {
    if (_subscription != null) {
      return;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();
    _subscription = _db.tankRef.onValue.listen(
      (event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          _waterLevel = (data['water_level'] as num?)?.toDouble();
          _isOn = data['status'] as bool?;
          _error = null;
        } else {
          _waterLevel = null;
          _isOn = null;
        }
        _isLoading = false;
        notifyListeners();
      },
      onError: (Object e) {
        _error = 'Failed to read tank data';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> stopListening() async {
    await _subscription?.cancel();
    _subscription = null;
    _waterLevel = null;
    _isOn = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  Future<void> toggleTank(bool isOn) async {
    try {
      await _db.tankRef.update({'status': isOn});
      _isOn = isOn;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update tank status';
      notifyListeners();
    }
  }
}
