import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class DbService {
  DbService({FirebaseApp? app, FirebaseDatabase? database})
      : _database = database ?? _resolveDatabase(app);

  final FirebaseDatabase _database;

  DatabaseReference get tankRef => _database.ref('tank');

  Future<void> ensureTankDataExists() async {
    final snapshot = await tankRef.get();
    if (!snapshot.exists) {
      await tankRef.set(_defaultTankPayload());
      return;
    }

    final value = snapshot.value;
    if (value is! Map) {
      await tankRef.set(_defaultTankPayload());
      return;
    }

    final updates = <String, Object?>{};
    final distance = value['distance_cm'];
    final manualControl = value['manual_control'];
    final manualCommand = value['manual_command'];
    final motorState = value['motor_state'];
    final updatedAt = value['updated_at'];

    if (distance is num) {
      final normalized = _normalizeDistance(distance.toDouble());
      if (normalized != distance) {
        updates['distance_cm'] = normalized;
      }
    } else {
      updates['distance_cm'] = 10.0;
    }

    final normalizedManualControl = _coerceToIntFlag(manualControl);
    if (normalizedManualControl != null) {
      if (manualControl != normalizedManualControl) {
        updates['manual_control'] = normalizedManualControl;
      }
    } else {
      updates['manual_control'] = 0;
    }

    final normalizedManualCommand = _coerceToIntFlag(manualCommand);
    if (normalizedManualCommand != null) {
      if (manualCommand != normalizedManualCommand) {
        updates['manual_command'] = normalizedManualCommand;
      }
    } else {
      updates['manual_command'] = 0;
    }

    if (motorState is String) {
      final normalized = _normalizeMotorState(motorState);
      if (motorState != normalized) {
        updates['motor_state'] = normalized;
      }
    } else {
      updates['motor_state'] = 'OFF';
    }

    if (updatedAt is! num) {
      updates['updated_at'] = ServerValue.timestamp;
    }

    if (updates.isNotEmpty) {
      await tankRef.update(updates);
    }
  }

  Future<void> setManualControl(bool enabled) async {
    await tankRef.update({
      'manual_control': enabled ? 1 : 0,
      if (!enabled) 'manual_command': 0,
      'updated_at': ServerValue.timestamp,
    });
  }

  Future<void> setManualCommand(bool enabled) async {
    await tankRef.update({
      'manual_command': enabled ? 1 : 0,
      'updated_at': ServerValue.timestamp,
    });
  }
}

FirebaseDatabase _resolveDatabase(FirebaseApp? app) {
  final resolvedApp = app ?? Firebase.app();
  final databaseUrl = resolvedApp.options.databaseURL;
  if (databaseUrl != null && databaseUrl.isNotEmpty) {
    return FirebaseDatabase.instanceFor(app: resolvedApp, databaseURL: databaseUrl);
  }
  return FirebaseDatabase.instanceFor(app: resolvedApp);
}

Map<String, Object?> _defaultTankPayload() {
  return {
    'distance_cm': 10.0,
    'manual_control': 0,
    'manual_command': 0,
    'motor_state': 'OFF',
    'updated_at': ServerValue.timestamp,
  };
}

double _normalizeDistance(double value) {
  final normalized = value.clamp(0, 10);
  return double.parse(normalized.toStringAsFixed(2));
}

String _normalizeMotorState(String raw) {
  final upper = raw.trim().toUpperCase();
  if (upper == 'ON') {
    return 'ON';
  }
  if (upper == 'OFF') {
    return 'OFF';
  }
  return upper.isNotEmpty ? upper : 'OFF';
}

int? _coerceToIntFlag(Object? value) {
  if (value is num) {
    return value != 0 ? 1 : 0;
  }
  if (value is bool) {
    return value ? 1 : 0;
  }
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == '1' || normalized == 'true' || normalized == 'on') {
      return 1;
    }
    if (normalized == '0' || normalized == 'false' || normalized == 'off') {
      return 0;
    }
  }
  return null;
}
