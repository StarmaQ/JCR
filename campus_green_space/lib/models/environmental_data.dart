class EnvironmentalData {
  final int? id;
  final int studentId;
  final double trashAmount; // in kg
  final double electricityUsage; // in kWh
  final double co2Emissions; // in kg
  final double recyclingPercentage; // 0-100%
  final DateTime timestamp;

  EnvironmentalData({
    this.id,
    required this.studentId,
    required this.trashAmount,
    required this.electricityUsage,
    required this.co2Emissions,
    required this.recyclingPercentage,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'trash_amount': trashAmount,
      'electricity_usage': electricityUsage,
      'co2_emissions': co2Emissions,
      'recycling_percentage': recyclingPercentage,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory EnvironmentalData.fromMap(Map<String, dynamic> map) {
    return EnvironmentalData(
      id: map['id'],
      studentId: map['student_id'],
      trashAmount: map['trash_amount'],
      electricityUsage: map['electricity_usage'],
      co2Emissions: map['co2_emissions'],
      recyclingPercentage: map['recycling_percentage'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
} 