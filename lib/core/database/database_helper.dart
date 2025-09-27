// lib/core/database/database_helper.dart
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'meditrack_pro.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Medicines table
    await db.execute('''
      CREATE TABLE medicines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        batch_number TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        mrp REAL NOT NULL,
        category TEXT NOT NULL,
        supplier TEXT NOT NULL,
        expiry_date TEXT NOT NULL,
        days_until_expiry INTEGER NOT NULL,
        suggested_discount INTEGER,
        discount_percentage REAL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Disposal records table
    await db.execute('''
      CREATE TABLE disposal_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        medicine_name TEXT NOT NULL,
        batch_number TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        disposal_date TEXT NOT NULL,
        disposal_method TEXT NOT NULL,
        status TEXT NOT NULL,
        category TEXT NOT NULL,
        supplier TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Sales records table
    await db.execute('''
      CREATE TABLE sales_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        medicine_id INTEGER NOT NULL,
        medicine_name TEXT NOT NULL,
        quantity_sold INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        total_amount REAL NOT NULL,
        customer_name TEXT,
        customer_phone TEXT,
        payment_method TEXT NOT NULL,
        sale_date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (medicine_id) REFERENCES medicines (id)
      )
    ''');

    // Inventory tracking table
    await db.execute('''
      CREATE TABLE inventory_tracking (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        medicine_id INTEGER NOT NULL,
        action_type TEXT NOT NULL,
        quantity_change INTEGER NOT NULL,
        previous_quantity INTEGER NOT NULL,
        new_quantity INTEGER NOT NULL,
        reason TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (medicine_id) REFERENCES medicines (id)
      )
    ''');
  }

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }
}
