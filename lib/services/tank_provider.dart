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
  bool _isWriting = false;
  DateTime? _updatedAt;
  String? _error;

  double? get waterLevel => _waterLevel;
  bool? get isOn => _isOn;
  bool get isLoading => _isLoading;
  bool get isWriting => _isWriting;
  DateTime? get updatedAt => _updatedAt;
  String? get error => _error;
  bool get hasData => _waterLevel != null && _isOn != null;
  bool get isConnected => hasData && _error == null;

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
        final raw = event.snapshot.value;
        if (raw is Map<dynamic, dynamic>) {
          final status = raw['status'];
          final level = raw['water_level'];
          if (status is bool && level is num) {
            _waterLevel = level.toDouble();
            _isOn = status;
            _updatedAt = DateTime.now();
            _error = null;
          } else {
            _waterLevel = null;
            _isOn = null;
            _error = 'Disconnected from tank. Trying to reconnect…';
          }
        } else {
          _waterLevel = null;
          _isOn = null;
          _error = 'Disconnected from tank. Trying to reconnect…';
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
    _isWriting = false;
    _updatedAt = null;
    _error = null;
    notifyListeners();
  }

  Future<bool> toggleTank(bool next) async {
    if (_isWriting) {
      return false;
    }
    final previous = _isOn;
    _isWriting = true;
    notifyListeners();
    try {
      await _db.tankRef.update({'status': next});
      _isOn = next;
      return true;
    } catch (e) {
      if (previous != null) {
        _isOn = previous;
      }
      return false;
    } finally {
      _isWriting = false;
      notifyListeners();
    }
  }
}
