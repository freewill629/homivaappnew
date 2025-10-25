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
      await tankRef.set({
        'status': false,
        'water_level_percent': 65.0,
        'updated_at': ServerValue.timestamp,
      });
      return;
    }

    final value = snapshot.value;
    if (value is! Map) {
      await tankRef.set({
        'status': false,
        'water_level_percent': 65.0,
        'updated_at': ServerValue.timestamp,
      });
      return;
    }

    final updates = <String, Object?>{};
    final status = value['status'];
    final percent = value['water_level_percent'];
    final legacyLevel = value['water_level'];
    final updatedAt = value['updated_at'];

    if (status is! bool) {
      updates['status'] = false;
    }

    if (percent is num) {
      final normalized = percent.toDouble().clamp(0, 100);
      if (normalized != percent) {
        updates['water_level_percent'] = normalized.toDouble();
      } else if (percent is int) {
        updates['water_level_percent'] = percent.toDouble();
      }
    } else if (legacyLevel is num) {
      final normalized = (legacyLevel.toDouble().clamp(0, 10) / 10.0) * 100.0;
      updates['water_level_percent'] = double.parse(normalized.toStringAsFixed(1));
      updates['water_level'] = null; // remove legacy field
    } else {
      updates['water_level_percent'] = 65.0;
    }

    if (updatedAt is! num) {
      updates['updated_at'] = ServerValue.timestamp;
    }

    if (updates.isNotEmpty) {
      await tankRef.update(updates);
    }
  }

  Future<void> updateTankState({bool? status, double? waterLevelPercent}) async {
    final updates = <String, Object?>{};
    if (status != null) {
      updates['status'] = status;
    }
    if (waterLevelPercent != null) {
      updates['water_level_percent'] = waterLevelPercent.clamp(0, 100).toDouble();
    }
    if (updates.isNotEmpty) {
      updates['updated_at'] = ServerValue.timestamp;
      await tankRef.update(updates);
    }
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
