import 'package:firebase_database/firebase_database.dart';

class DbService {
  DbService({FirebaseDatabase? database}) : _database = database ?? FirebaseDatabase.instance;

  final FirebaseDatabase _database;

  DatabaseReference get tankRef => _database.ref('tank');
}
