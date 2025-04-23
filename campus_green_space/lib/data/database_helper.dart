import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/student.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  static bool _databaseInitialized = false;

  // Global university-wide metrics
  static const int _totalTreesPlanted = 12; // Sample global value
  static const int _totalSolarPanelsInstalled = 5; // Sample global value

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  // Getter for global metrics
  int get totalTreesPlanted => _totalTreesPlanted;
  int get totalSolarPanelsInstalled => _totalSolarPanelsInstalled;

  Future<Database> get database async {
    if (_database != null) return _database!;
    try {
      _database = await _initDatabase();
      return _database!;
    } catch (e) {
      print('Error getting database: $e');
      rethrow;
    }
  }

  Future<Database> _initDatabase() async {
    try {
      String dbName = 'campus_green_space.db';
      
      // Platform-specific database initialization
      late Database db;
      if (kIsWeb) {
        // Web specific implementation
        db = await databaseFactory.openDatabase(
          dbName,
          options: OpenDatabaseOptions(
            version: 1,
            onCreate: _onCreate,
          ),
        );
      } else {
        // Mobile/Desktop implementation
        String path = join(await getDatabasesPath(), dbName);
        db = await openDatabase(
          path,
          version: 1,
          onCreate: _onCreate,
        );
      }
      
      // Check if we need to generate data
      if (!_databaseInitialized) {
        try {
          // Check if the students table exists
          await db.rawQuery('SELECT COUNT(*) FROM sqlite_master WHERE type = ? AND name = ?', 
                           ['table', 'students']);
          
          // Check if there's data in the table
          final count = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM students')
          );
          
          // Generate mock data if no data exists
          if (count == 0) {
            await _generateMockData(db);
          }
          
          _databaseInitialized = true;
        } catch (e) {
          // Table likely doesn't exist, try to create it
          await _onCreate(db, 1);
        }
      }
      
      return db;
    } catch (e) {
      print('Database initialization failed: $e');
      rethrow;
    }
  }

  Future _onCreate(Database db, int version) async {
    try {
      // Create the students table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS students(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          universityId TEXT,
          carbonPoints INTEGER,
          waterSaved INTEGER,
          co2Reduced INTEGER
        )
      ''');
      
      // Create the daily university stats table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS daily_university_stats(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT,
          co2Reduced INTEGER,
          waterSaved INTEGER,
          carbonPoints INTEGER
        )
      ''');

      // Generate mock data
      await _generateMockData(db);
      
      // Generate daily university stats for the past 30 days
      await _generateDailyUniversityStats(db);

      _databaseInitialized = true;
    } catch (e) {
      print('Error creating database schema: $e');
      // Don't rethrow to avoid app crashes, we'll try to recover
    }
  }

  // Insert a student into the database
  Future<int> insertStudent(Student student) async {
    Database db = await database;
    return await db.insert('students', student.toMap());
  }

  // Get all students
  Future<List<Student>> getStudents() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('students');
    return List.generate(maps.length, (i) {
      return Student.fromMap(maps[i]);
    });
  }

  // Get a student by id
  Future<Student?> getStudent(int id) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Student.fromMap(maps.first);
    }
    return null;
  }

  // Get a student by name
  Future<Student?> getStudentByName(String name) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: 'name = ?',
      whereArgs: [name],
    );

    if (maps.isNotEmpty) {
      return Student.fromMap(maps.first);
    }
    return null;
  }

  // Update a student
  Future<int> updateStudent(Student student) async {
    Database db = await database;
    return await db.update(
      'students',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  // Delete a student
  Future<int> deleteStudent(int id) async {
    Database db = await database;
    return await db.delete(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get the total count of students
  Future<int> getStudentCount() async {
    Database db = await database;
    return Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM students'),
    ) ?? 0;
  }

  // Generate mock data for 100 students
  Future<void> _generateMockData(Database db) async {
    final random = Random();
    
    // List of Tunisian first names
    final firstNames = [
      'Mohamed', 'Ahmed', 'Ali', 'Youssef', 'Aymen', 'Sami', 'Bilel', 'Karim', 'Hamza', 'Seif',
      'Amine', 'Slim', 'Mehdi', 'Wassim', 'Tarek', 'Khaled', 'Hatem', 'Zied', 'Nabil', 'Ridha',
      'Leila', 'Fatma', 'Maryam', 'Ines', 'Sana', 'Amira', 'Yasmine', 'Rania', 'Asma', 'Salma',
      'Nour', 'Nadia', 'Rim', 'Samia', 'Sirine', 'Emna', 'Lina', 'Nesrine', 'Houda', 'Souad',
      'Olfa', 'Dorsaf', 'Mariem', 'Amel', 'Hajer', 'Sarra', 'Lamia', 'Afef', 'Aida', 'Hela'
    ];
    
    // List of Tunisian last names
    final lastNames = [
      'Ben Salah', 'Ben Ali', 'Trabelsi', 'Maatoug', 'Chaabane', 'Hmidi', 'Jebali', 'Zitouni', 'Guermazi', 'Chebbi',
      'Belhadj', 'Abidi', 'Mekni', 'Karoui', 'Gharbi', 'Tounsi', 'Laabidi', 'Chatti', 'Ferchichi', 'Bouazizi',
      'Bouslama', 'Jlassi', 'Ammar', 'Bouzid', 'Nasri', 'Karray', 'Jendoubi', 'Tlili', 'Msalmi', 'Sfaxi',
      'Slimani', 'Hamdi', 'Souilah', 'Letaief', 'Ghorbel', 'Jerbi', 'Kasmi', 'Touil', 'Dridi', 'Lahmar',
      'Rezgui', 'Bouzaiene', 'Bahri', 'Selmi', 'Guizani', 'Mejri', 'Chokri', 'Saadi', 'Cherni', 'Oueslati'
    ];

    // Values distribution for a university with low environmental engagement:
    // 70% of students will have minimal engagement
    // 25% will have moderate engagement
    // 5% will be highly engaged environmental champions

    // First insert Mohamed Maatoug with realistic but decent stats
    await db.insert('students', {
      'name': 'Mohamed Maatoug',
      'universityId': '2021CS432',
      'carbonPoints': 127,  // Realistic but decent score
      'waterSaved': 23,     // Realistic value
      'co2Reduced': 47,     // Realistic value
    });

    // Generate 99 more students with realistic data for a university with low environmental engagement
    for (int i = 0; i < 99; i++) {
      final firstName = firstNames[random.nextInt(firstNames.length)];
      final lastName = lastNames[random.nextInt(lastNames.length)];
      final name = '$firstName $lastName';
      
      // Generate a university ID like "2023CS123"
      final year = 2020 + random.nextInt(4); // Between 2020 and 2023
      final prefix = ['CS', 'EN', 'BU', 'BI', 'MA', 'AR', 'ME', 'ED'][random.nextInt(8)];
      final studentNum = 100 + random.nextInt(900); // 3-digit number
      final universityId = '$year$prefix$studentNum';
      
      // Determine student category
      final engagementLevel = random.nextDouble();
      
      int carbonPoints;
      int waterSaved;
      int co2Reduced;
      
      if (engagementLevel < 0.70) {
        // 70% - Low engagement students
        carbonPoints = 5 + random.nextInt(25); // 5-29
        waterSaved = random.nextInt(5); // 0-4
        co2Reduced = random.nextInt(10); // 0-9
      } else if (engagementLevel < 0.95) {
        // 25% - Moderate engagement students
        carbonPoints = 30 + random.nextInt(70); // 30-99
        waterSaved = 5 + random.nextInt(15); // 5-19
        co2Reduced = 10 + random.nextInt(20); // 10-29
      } else {
        // 5% - High engagement students (environmental champions)
        carbonPoints = 100 + random.nextInt(150); // 100-249
        waterSaved = 20 + random.nextInt(30); // 20-49
        co2Reduced = 30 + random.nextInt(50); // 30-79
      }
      
      await db.insert('students', {
        'name': name,
        'universityId': universityId,
        'carbonPoints': carbonPoints,
        'waterSaved': waterSaved,
        'co2Reduced': co2Reduced,
      });
    }
  }

  // Get university-wide statistics
  Future<Map<String, dynamic>> getUniversityStats() async {
    Database db = await database;
    
    final totalStudents = await getStudentCount();
    
    final carbonPointsResult = await db.rawQuery('SELECT SUM(carbonPoints) FROM students');
    final waterSavedResult = await db.rawQuery('SELECT SUM(waterSaved) FROM students');
    final co2ReducedResult = await db.rawQuery('SELECT SUM(co2Reduced) FROM students');
    
    return {
      'totalStudents': totalStudents,
      'totalCarbonPoints': carbonPointsResult.first['SUM(carbonPoints)'] ?? 0,
      'totalWaterSaved': waterSavedResult.first['SUM(waterSaved)'] ?? 0,
      'totalCO2Reduced': co2ReducedResult.first['SUM(co2Reduced)'] ?? 0,
      'totalTreesPlanted': _totalTreesPlanted,
      'totalSolarPanelsInstalled': _totalSolarPanelsInstalled,
    };
  }

  // Get top students by carbon points
  Future<List<Student>> getTopStudents({int limit = 10}) async {
    Database db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      orderBy: 'carbonPoints DESC',
      limit: limit,
    );
    
    return List.generate(maps.length, (i) {
      return Student.fromMap(maps[i]);
    });
  }

  // Dummy method to maintain compatibility with any code that might still call this
  Future<List<Map<String, dynamic>>> getDepartmentStats() async {
    // Return an empty list since departments are no longer tracked
    return [];
  }

  // Generate mock daily stats for the past 30 days
  Future<void> _generateDailyUniversityStats(Database db) async {
    final now = DateTime.now();
    final random = Random();
    // Define a clear trend: base + increment per day + random noise
    final baseCo2 = 2000;
    final incrementCo2 = 10;
    final baseWater = 500;
    final incrementWater = 5;
    final baseCarbon = 1000;
    final incrementCarbon = 20;
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: 29 - i));
      final noiseCo2 = random.nextInt(20) - 10; // -10 to +9
      final noiseWater = random.nextInt(10) - 5;
      final noiseCarbon = random.nextInt(40) - 20;
      final co2 = baseCo2 + incrementCo2 * i + noiseCo2;
      final water = baseWater + incrementWater * i + noiseWater;
      final carbonPoints = baseCarbon + incrementCarbon * i + noiseCarbon;
      await db.insert('daily_university_stats', {
        'date': date.toIso8601String(),
        'co2Reduced': co2,
        'waterSaved': water,
        'carbonPoints': carbonPoints,
      });
    }
  }

  // Fetch daily university stats ordered by date
  Future<List<Map<String, dynamic>>> getDailyUniversityStats() async {
    final db = await database;
    return await db.query('daily_university_stats', orderBy: 'date');
  }

  // Compute annual predictions for CO₂, water, and carbon points using linear regression
  Future<Map<String, dynamic>> getUniversityAnnualPrediction() async {
    final dailyStats = await getDailyUniversityStats();
    final n = dailyStats.length;
    final xs = List<double>.generate(n, (i) => i.toDouble());
    // Helper to compute slope and intercept
    double computeSlope(List<double> ys, double xMean, double yMean, double varX) {
      double cov = 0;
      for (int i = 0; i < n; i++) {
        cov += (xs[i] - xMean) * (ys[i] - yMean);
      }
      return cov / varX;
    }
    double xMean = xs.reduce((a, b) => a + b) / n;
    double varX = xs.map((x) => (x - xMean) * (x - xMean)).reduce((a, b) => a + b);
    // Prepare Y lists
    List<double> co2List = dailyStats.map((e) => (e['co2Reduced'] as int).toDouble()).toList();
    List<double> waterList = dailyStats.map((e) => (e['waterSaved'] as int).toDouble()).toList();
    List<double> carbonList = dailyStats.map((e) => (e['carbonPoints'] as int).toDouble()).toList();
    // Compute regression for each
    double yMeanCo2 = co2List.reduce((a, b) => a + b) / n;
    double slopeCo2 = computeSlope(co2List, xMean, yMeanCo2, varX);
    double interceptCo2 = yMeanCo2 - slopeCo2 * xMean;
    double predictedDailyCo2 = slopeCo2 * n + interceptCo2;
    double predictedAnnualCo2 = predictedDailyCo2 * 365;
    double yMeanWater = waterList.reduce((a, b) => a + b) / n;
    double slopeWater = computeSlope(waterList, xMean, yMeanWater, varX);
    double interceptWater = yMeanWater - slopeWater * xMean;
    double predictedDailyWater = slopeWater * n + interceptWater;
    double predictedAnnualWater = predictedDailyWater * 365;
    double yMeanCarbon = carbonList.reduce((a, b) => a + b) / n;
    double slopeCarbon = computeSlope(carbonList, xMean, yMeanCarbon, varX);
    double interceptCarbon = yMeanCarbon - slopeCarbon * xMean;
    double predictedDailyCarbon = slopeCarbon * n + interceptCarbon;
    double predictedAnnualCarbon = predictedDailyCarbon * 365;
    // Compute current totals
    double sumCurrentCo2 = co2List.reduce((a, b) => a + b);
    double sumCurrentWater = waterList.reduce((a, b) => a + b);
    double sumCurrentCarbon = carbonList.reduce((a, b) => a + b);

    // Compute current annual totals based on average daily values
    double avgDailyCo2 = sumCurrentCo2 / n;
    double currentAnnualCo2 = avgDailyCo2 * 365;
    double avgDailyWater = sumCurrentWater / n;
    double currentAnnualWater = avgDailyWater * 365;
    double avgDailyCarbon = sumCurrentCarbon / n;
    double currentAnnualCarbon = avgDailyCarbon * 365;

    // Compute percentage changes
    double pctCo2 = ((predictedAnnualCo2 - currentAnnualCo2) / currentAnnualCo2) * 100;
    double pctWater = ((predictedAnnualWater - currentAnnualWater) / currentAnnualWater) * 100;
    double pctCarbon = ((predictedAnnualCarbon - currentAnnualCarbon) / currentAnnualCarbon) * 100;

    // Return the predictions
    return {
      'currentAnnualCO2': currentAnnualCo2.round(),
      'predictedAnnualCO2': predictedAnnualCo2.round(),
      'percentageCo2Change': pctCo2,
      'currentAnnualWater': currentAnnualWater.round(),
      'predictedAnnualWater': predictedAnnualWater.round(),
      'percentageWaterChange': pctWater,
      'currentAnnualCarbonPoints': currentAnnualCarbon.round(),
      'predictedAnnualCarbonPoints': predictedAnnualCarbon.round(),
      'percentageCarbonChange': pctCarbon,
    };
  }
} 