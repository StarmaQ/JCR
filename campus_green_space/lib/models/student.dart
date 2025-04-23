class Student {
  final int? id;
  final String name;
  final String universityId;
  final int carbonPoints;
  final int waterSaved;
  final int co2Reduced;

  Student({
    this.id,
    required this.name,
    required this.universityId,
    required this.carbonPoints,
    required this.waterSaved,
    required this.co2Reduced,
  });

  // Convert Student to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'universityId': universityId,
      'carbonPoints': carbonPoints,
      'waterSaved': waterSaved,
      'co2Reduced': co2Reduced,
    };
  }

  // Create Student from Map
  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      name: map['name'],
      universityId: map['universityId'],
      carbonPoints: map['carbonPoints'],
      waterSaved: map['waterSaved'],
      co2Reduced: map['co2Reduced'],
    );
  }

  // Create a copy of Student with some changes
  Student copyWith({
    int? id,
    String? name,
    String? universityId,
    int? carbonPoints,
    int? waterSaved,
    int? co2Reduced,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      universityId: universityId ?? this.universityId,
      carbonPoints: carbonPoints ?? this.carbonPoints,
      waterSaved: waterSaved ?? this.waterSaved,
      co2Reduced: co2Reduced ?? this.co2Reduced,
    );
  }
} 