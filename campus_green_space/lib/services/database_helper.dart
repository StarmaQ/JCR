import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/student.dart';
import '../models/environmental_data.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('campus_green_space.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create students table
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        department TEXT NOT NULL,
        student_id TEXT NOT NULL UNIQUE,
        created_at TEXT NOT NULL
      )
    ''');

    // Create environmental_data table
    await db.execute('''
      CREATE TABLE environmental_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        trash_amount REAL NOT NULL,
        electricity_usage REAL NOT NULL,
        co2_emissions REAL NOT NULL,
        recycling_percentage REAL NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (student_id) REFERENCES students (id)
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        ALTER TABLE environmental_data
        ADD COLUMN recycling_percentage REAL NOT NULL DEFAULT 0
      ''');
    }
  }

  // Student operations
  Future<int> insertStudent(Student student) async {
    final db = await database;
    return await db.insert('students', student.toMap());
  }

  Future<Student?> getStudent(int id) async {
    final db = await database;
    final maps = await db.query(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Student.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Student>> getAllStudents() async {
    final db = await database;
    final maps = await db.query('students');
    return maps.map((map) => Student.fromMap(map)).toList();
  }

  // Environmental data operations
  Future<int> insertEnvironmentalData(EnvironmentalData data) async {
    final db = await database;
    return await db.insert('environmental_data', data.toMap());
  }

  Future<List<EnvironmentalData>> getStudentEnvironmentalData(int studentId) async {
    final db = await database;
    final maps = await db.query(
      'environmental_data',
      where: 'student_id = ?',
      whereArgs: [studentId],
      orderBy: 'timestamp DESC',
    );
    return maps.map((map) => EnvironmentalData.fromMap(map)).toList();
  }

  Future<List<EnvironmentalData>> getEnvironmentalDataByDateRange(
    int studentId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final maps = await db.query(
      'environmental_data',
      where: 'student_id = ? AND timestamp BETWEEN ? AND ?',
      whereArgs: [
        studentId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'timestamp DESC',
    );
    return maps.map((map) => EnvironmentalData.fromMap(map)).toList();
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    db.close();
  }
} 