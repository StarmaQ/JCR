import 'package:flutter/material.dart';

class Bin {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double fillLevel; // 0-100%
  final String type; // recycling, trash, compost
  final DateTime lastUpdated;
  final double weight; // in kilograms
  final Map<String, double> materialComposition; // percentage of different materials

  Bin({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.fillLevel,
    required this.type,
    this.id = '',
    DateTime? lastUpdated,
    this.weight = 0.0,
    Map<String, double>? materialComposition,
  })  : lastUpdated = lastUpdated ?? DateTime.now(),
        materialComposition = materialComposition ?? {
          'paper': 0.0,
          'plastic': 0.0,
          'metal': 0.0,
          'glass': 0.0,
          'organic': 0.0,
          'other': 0.0,
        };

  Color get fillColor {
    if (fillLevel < 30) {
      return const Color(0xFF4CAF50); // Green
    } else if (fillLevel < 70) {
      return const Color(0xFFFF9800); // Orange
    } else {
      return const Color(0xFFF44336); // Red
    }
  }

  String get fillStatus {
    if (fillLevel < 30) {
      return 'Low';
    } else if (fillLevel < 70) {
      return 'Medium';
    } else {
      return 'High';
    }
  }

  // Calculate CO2 impact based on bin type and contents
  double calculateCO2Impact() {
    if (type == 'recycling') {
      // Calculate CO2 savings from recycling
      return -(
        (materialComposition['paper']! * weight * 0.8) + // Paper recycling
        (materialComposition['plastic']! * weight * 1.5) + // Plastic recycling
        (materialComposition['metal']! * weight * 2.0) + // Metal recycling
        (materialComposition['glass']! * weight * 0.3) // Glass recycling
      );
    } else {
      // Calculate CO2 emissions from landfill
      return weight * 0.1; // 0.1 kg CO2 per kg of waste
    }
  }

  // Get material composition as a formatted string
  String getMaterialCompositionString() {
    final List<String> materials = [];
    materialComposition.forEach((material, percentage) {
      if (percentage > 0) {
        materials.add('${(percentage * 100).toStringAsFixed(1)}% $material');
      }
    });
    return materials.join(', ');
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'fillLevel': fillLevel,
      'type': type,
      'lastUpdated': lastUpdated.toIso8601String(),
      'weight': weight,
      'materialComposition': materialComposition,
    };
  }

  factory Bin.fromMap(Map<String, dynamic> map) {
    return Bin(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      fillLevel: map['fillLevel']?.toDouble() ?? 0.0,
      type: map['type'] ?? '',
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.parse(map['lastUpdated'])
          : DateTime.now(),
      weight: map['weight']?.toDouble() ?? 0.0,
      materialComposition: Map<String, double>.from(map['materialComposition'] ?? {
        'paper': 0.0,
        'plastic': 0.0,
        'metal': 0.0,
        'glass': 0.0,
        'organic': 0.0,
        'other': 0.0,
      }),
    );
  }
} 