/*
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'izmirim_v10.db');

    return await openDatabase(
      path,
      version: 3, // Versiyonu artırdık
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE transactions (id INTEGER PRIMARY KEY AUTOINCREMENT, user_type TEXT, amount REAL, date TEXT)');
        await db.execute('CREATE TABLE user_data (user_type TEXT PRIMARY KEY, balance REAL)');
        await db.insert('user_data', {'user_type': 'Tam', 'balance': 150.0});
        await db.insert('user_data', {'user_type': 'Öğrenci', 'balance': 50.0});
        await db.insert('user_data', {'user_type': 'Öğretmen', 'balance': 100.0});
        await db.insert('user_data', {'user_type': 'Emekli', 'balance': 15.0});
      },
    );
  }

  Future<double> getBalance(String userType) async {
    final db = await database;
    final result = await db.query('user_data', where: 'user_type = ?', whereArgs: [userType]);
    return result.isNotEmpty ? (result.first['balance'] as num).toDouble() : 0.0;
  }

  Future<Map<String, dynamic>> processTransaction(String userType) async {
    final db = await database;
    // Transaction içinde işlem yapıyoruz ki APK'da veri kilitlenmesin
    return await db.transaction((txn) async {
      final List<Map<String, dynamic>> user = await txn.query('user_data', where: 'user_type = ?', whereArgs: [userType]);
      double bakiye = (user.first['balance'] as num).toDouble();
      double fiyat = (userType == 'Öğrenci') ? 17.5 : (userType == 'Öğretmen') ? 20.0 : (userType == 'Emekli') ? 0.0 : 35.0;

      if (bakiye >= fiyat) {
        await txn.update('user_data', {'balance': bakiye - fiyat}, where: 'user_type = ?', whereArgs: [userType]);
        await txn.insert('transactions', {'user_type': userType, 'amount': fiyat, 'date': DateTime.now().toIso8601String()});
        return {'success': true, 'amount': fiyat};
      }
      return {'success': false, 'amount': fiyat};
    });
  }

  Future<List<Map<String, dynamic>>> getTransactions(String userType) async {
    final db = await database;
    return await db.query('transactions', where: 'user_type = ?', whereArgs: [userType], orderBy: 'id DESC');
  }

  Future<void> addBalance(String userType, double amount) async {
    final db = await database;
    double bakiye = await getBalance(userType);
    await db.update('user_data', {'balance': bakiye + amount}, where: 'user_type = ?', whereArgs: [userType]);
  }
}
*/
