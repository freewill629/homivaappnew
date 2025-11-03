import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import 'db_service.dart';

class TankProvider extends ChangeNotifier {
  TankProvider({required DbService db}) : _db = db;

  DbService _db;
  StreamSubscription<DatabaseEvent>? _subscription;

  double? _waterLevelPercent;
  double? _distanceFromTop;
  bool? _isOn;
  bool? _manualControlEnabled;
  bool? _manualCommand;
  bool _isLoading = false;
  bool _isWriting = false;
  bool _isUpdatingManualControl = false;
  DateTime? _updatedAt;
  String? _error;

  double? get waterLevelPercent => _waterLevelPercent;
  @Deprecated('Use waterLevelPercent instead')
  double? get waterLevel =>
      _waterLevelPercent != null ? _waterLevelPercent! / 10 : null;
  bool? get isOn => _isOn;
  double? get distanceFromTop => _distanceFromTop;
  bool? get manualControlEnabled => _manualControlEnabled;
  bool? get manualCommand => _manualCommand;
  bool get isLoading => _isLoading;
  bool get isWriting => _isWriting;
  bool get isUpdatingManualControl => _isUpdatingManualControl;
  DateTime? get updatedAt => _updatedAt;
  String? get error => _error;
  bool get hasLevel => _waterLevelPercent != null;
  bool get hasStatus =>
      _isOn != null || (_manualCommand != null && (_manualControlEnabled ?? false));
  bool get hasData => hasLevel || hasStatus;
  bool get canControl => (_manualControlEnabled ?? false) && _error == null;
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
    _subscription = _db.dataRef.onValue.listen(
      (event) {
        final raw = event.snapshot.value;
        if (raw is Map<dynamic, dynamic>) {
          final distance = raw['distance_cm'];
          final manualControl = raw['manual_control'];
          final manualCommand = raw['manual_command'];
          final motorState = raw['motor_state'];
          final timestamp = raw['updated_at'];

          var hasMeaningfulData = false;

          if (distance is num) {
            _distanceFromTop =
                double.parse(distance.toDouble().toStringAsFixed(2));
            final percent = _distanceToPercent(_distanceFromTop!);
            _waterLevelPercent =
                double.parse(percent.toStringAsFixed(1));
            hasMeaningfulData = true;
          }

          final parsedManualControl = _parseBool(manualControl);
          if (parsedManualControl != null) {
            _manualControlEnabled = parsedManualControl;
            hasMeaningfulData = true;
          }

          final parsedManualCommand = _parseBool(manualCommand);
          if (parsedManualCommand != null) {
            _manualCommand = parsedManualCommand;
            hasMeaningfulData = true;
          }

          final parsedMotorState = _parseMotorState(motorState);
          if (parsedMotorState != null) {
            _isOn = parsedMotorState;
            hasMeaningfulData = true;
          } else if ((_manualControlEnabled ?? false) &&
              _manualCommand != null) {
            _isOn = _manualCommand;
          }

          if (timestamp is num) {
            _updatedAt = DateTime.fromMillisecondsSinceEpoch(
              timestamp.toInt(),
              isUtc: true,
            ).toLocal();
          }

          if (hasMeaningfulData) {
            _updatedAt ??= DateTime.now();
            _error = null;
          } else {
            _resetRealtimeValues();
            _error = 'Disconnected from tank. Trying to reconnect…';
          }
        } else {
          _resetRealtimeValues();
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
    _resetRealtimeValues();
    _isLoading = false;
    _isWriting = false;
    _isUpdatingManualControl = false;
    _error = null;
    notifyListeners();
  }

  Future<bool> toggleTank(bool next) async {
    if (_isWriting || !(_manualControlEnabled ?? false)) {
      return false;
    }
    final previousCommand = _manualCommand;
    _isWriting = true;
    notifyListeners();
    try {
      await _db.setManualCommand(next);
      _manualCommand = next;
      if (_manualControlEnabled ?? false) {
        _isOn = next;
      }
      _updatedAt = DateTime.now();
      _error = null;
      return true;
    } catch (e) {
      if (previousCommand != null) {
        _manualCommand = previousCommand;
      }
      return false;
    } finally {
      _isWriting = false;
      notifyListeners();
    }
  }

  Future<bool> toggleManualControl(bool enable) async {
    if (_isUpdatingManualControl) {
      return false;
    }
    final previous = _manualControlEnabled;
    _isUpdatingManualControl = true;
    notifyListeners();
    try {
      await _db.setManualControl(enable);
      _manualControlEnabled = enable;
      if (!enable) {
        _manualCommand = false;
      }
      _updatedAt = DateTime.now();
      _error = null;
      return true;
    } catch (e) {
      if (previous != null) {
        _manualControlEnabled = previous;
      }
      return false;
    } finally {
      _isUpdatingManualControl = false;
      notifyListeners();
    }
  }

  void _resetRealtimeValues() {
    _waterLevelPercent = null;
    _distanceFromTop = null;
    _isOn = null;
    _manualControlEnabled = null;
    _manualCommand = null;
    _updatedAt = null;
  }
}

bool? _parseBool(Object? value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == 'on' || normalized == '1') {
      return true;
    }
    if (normalized == 'false' || normalized == 'off' || normalized == '0') {
      return false;
    }
  }
  return null;
}

bool? _parseMotorState(Object? value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    final normalized = value.trim().toUpperCase();
    if (normalized == 'ON') {
      return true;
    }
    if (normalized == 'OFF') {
      return false;
    }
  }
  return null;
}

double _distanceToPercent(double distanceCm) {
  const totalHeight = 10.0;
  final clamped = distanceCm.clamp(0, totalHeight);
  final percent = (totalHeight - clamped) * 10;
  return percent.clamp(0, 100);
}
