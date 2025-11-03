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
    }
  }

  Future<void> setManualControl(bool enabled) async {
    await dataRef.update({
      'manual_control': enabled ? 1 : 0,
      if (!enabled) 'manual_command': 0,
      'updated_at': ServerValue.timestamp,
    });
  }

  Future<void> setManualCommand(bool enabled) async {
    await dataRef.update({
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

Map<String, Object?> _defaultDataPayload() {
  return {
    'manual_control': 0,
    'manual_command': 0,
    'motor_state': 'OFF',
    'updated_at': ServerValue.timestamp,
  };
}
