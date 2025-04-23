import '../data/database_helper.dart';
import '../models/student.dart';

class StudentService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Get all students
  Future<List<Student>> getAllStudents() async {
    return await _databaseHelper.getStudents();
  }

  // Get a student by ID
  Future<Student?> getStudentById(int id) async {
    return await _databaseHelper.getStudent(id);
  }

  // Get university stats
  Future<Map<String, dynamic>> getUniversityStats() async {
    return await _databaseHelper.getUniversityStats();
  }

  // Get top students
  Future<List<Student>> getTopStudents({int limit = 10}) async {
    return await _databaseHelper.getTopStudents(limit: limit);
  }

  // Update a student's environmental metrics
  Future<void> updateStudentMetrics(
    int studentId, {
    int? additionalCarbonPoints,
    int? additionalWaterSaved,
    int? additionalCO2Reduced,
  }) async {
    // Get current student data
    final student = await _databaseHelper.getStudent(studentId);
    if (student == null) return;

    // Create updated student object
    final updatedStudent = student.copyWith(
      carbonPoints: student.carbonPoints + (additionalCarbonPoints ?? 0),
      waterSaved: student.waterSaved + (additionalWaterSaved ?? 0),
      co2Reduced: student.co2Reduced + (additionalCO2Reduced ?? 0),
    );

    // Update in database
    await _databaseHelper.updateStudent(updatedStudent);
  }
} 