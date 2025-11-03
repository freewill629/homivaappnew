import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class DbService {
  DbService({FirebaseApp? app, FirebaseDatabase? database})
      : _database = database ?? _resolveDatabase(app);

  final FirebaseDatabase _database;

  DatabaseReference get dataRef => _database.ref('data');

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
