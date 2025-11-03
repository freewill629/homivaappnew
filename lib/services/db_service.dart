import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class DbService {
  DbService({FirebaseApp? app, FirebaseDatabase? database})
      : _database = database ?? _resolveDatabase(app);

  final FirebaseDatabase _database;

  DatabaseReference get dataRef => _database.ref('data');

  Future<void> ensureDataExists() async {
    final snapshot = await dataRef.get();
    if (!snapshot.exists) {
      await dataRef.set(_defaultDataPayload());
      return;
    }

    final value = snapshot.value;
    if (value is! Map) {
      await dataRef.set(_defaultDataPayload());
      return;
    }

    final updates = <String, Object?>{};
    final manualControl = value['manual_control'];
    final manualCommand = value['manual_command'];
    final motorState = value['motor_state'];
    final updatedAt = value['updated_at'];

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
      await dataRef.update(updates);
    }
  }

  Future<void> setManualControl(bool enabled) async {
    await dataRef.child('manual_control').set(enabled ? 1 : 0);
    if (!enabled) {
      await dataRef.child('manual_command').set(0);
    }
    await dataRef.child('updated_at').set(ServerValue.timestamp);
  }

  Future<void> setManualCommand(bool enabled) async {
    await dataRef.child('manual_command').set(enabled ? 1 : 0);
    await dataRef.child('updated_at').set(ServerValue.timestamp);
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

Map<String, Object?> _defaultDataPayload() {
  return {
    'manual_control': 0,
    'manual_command': 0,
    'motor_state': 'OFF',
    'updated_at': ServerValue.timestamp,
  };
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
