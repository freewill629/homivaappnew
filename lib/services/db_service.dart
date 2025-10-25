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
    final status = value['status'];
    final percent = value['water_level_percent'];
    final legacyLevel = value['water_level'];
    final updatedAt = value['updated_at'];

    if (status is! bool) {
      updates['status'] = false;
    }

    if (percent is num) {
      final normalizedPercent = _normalizePercent(percent.toDouble());
      updates['water_level_percent'] = normalizedPercent;
      updates['water_level'] = _percentToLevel(normalizedPercent);
    } else if (legacyLevel is num) {
      final normalizedLevel = legacyLevel.toDouble().clamp(0, 10);
      updates['water_level'] = double.parse(normalizedLevel.toStringAsFixed(1));
      updates['water_level_percent'] =
          double.parse((normalizedLevel * 10).toStringAsFixed(1));
    } else {
      updates['water_level_percent'] = 65.0;
      updates['water_level'] = 6.5;
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
      final normalizedPercent = _normalizePercent(waterLevelPercent);
      updates['water_level_percent'] = normalizedPercent;
      updates['water_level'] = _percentToLevel(normalizedPercent);
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

Map<String, Object?> _defaultTankPayload() {
  return {
    'status': false,
    'water_level': 6.5,
    'water_level_percent': 65.0,
    'updated_at': ServerValue.timestamp,
  };
}

double _percentToLevel(double percent) {
  final normalized = percent.clamp(0, 100) / 10.0;
  return double.parse(normalized.toStringAsFixed(1));
}

double _normalizePercent(double percent) {
  final normalized = percent.clamp(0, 100);
  return double.parse(normalized.toStringAsFixed(1));
}
