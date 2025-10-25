import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import 'db_service.dart';

class TankProvider extends ChangeNotifier {
  TankProvider({required DbService db}) : _db = db;

  DbService _db;
  StreamSubscription<DatabaseEvent>? _subscription;

  double? _waterLevelPercent;
  bool? _isOn;
  bool _isLoading = false;
  bool _isWriting = false;
  DateTime? _updatedAt;
  String? _error;

  double? get waterLevelPercent => _waterLevelPercent;
  @Deprecated('Use waterLevelPercent instead')
  double? get waterLevel =>
      _waterLevelPercent != null ? _waterLevelPercent! / 10 : null;
  bool? get isOn => _isOn;
  bool get isLoading => _isLoading;
  bool get isWriting => _isWriting;
  DateTime? get updatedAt => _updatedAt;
  String? get error => _error;
  bool get hasLevel => _waterLevelPercent != null;
  bool get hasStatus => _isOn != null;
  bool get hasData => hasLevel || hasStatus;
  bool get canControl => hasStatus && _error == null;
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
    try {
      await _db.ensureTankDataExists();
    } catch (e) {
      _error = 'Failed to initialize tank data';
      notifyListeners();
    }
    _subscription = _db.tankRef.onValue.listen(
      (event) {
        final raw = event.snapshot.value;
        if (raw is Map<dynamic, dynamic>) {
          final status = raw['status'];
          final levelPercent = raw['water_level_percent'];
          final levelValue = raw['water_level'];
          if (status is bool) {
            _isOn = status;
          }
          if (levelValue is num) {
            final normalizedLevel = levelValue.toDouble().clamp(0, 10);
            final asPercent = normalizedLevel * 10.0;
            _waterLevelPercent =
                double.parse(asPercent.clamp(0, 100).toStringAsFixed(1));
          } else if (levelPercent is num) {
            final normalized = levelPercent.toDouble().clamp(0, 100);
            _waterLevelPercent = double.parse(normalized.toStringAsFixed(1));
          }
          final timestamp = raw['updated_at'];
          if (timestamp is num) {
            _updatedAt =
                DateTime.fromMillisecondsSinceEpoch(timestamp.toInt(), isUtc: true).toLocal();
          }
          if (status is bool || levelPercent is num || levelValue is num) {
            _updatedAt ??= DateTime.now();
            _error = null;
          } else {
            _waterLevelPercent = null;
            _isOn = null;
            _updatedAt = null;
            _error = 'Disconnected from tank. Trying to reconnect…';
          }
        } else {
          _waterLevelPercent = null;
          _isOn = null;
          _updatedAt = null;
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
    _waterLevelPercent = null;
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
      final simulatedLevel = next ? 9.2 : 4.8;
      await _db.updateTankState(status: next, waterLevel: simulatedLevel);
      _isOn = next;
      _waterLevelPercent = double.parse((simulatedLevel * 10).toStringAsFixed(1));
      _updatedAt = DateTime.now();
      _error = null;
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
