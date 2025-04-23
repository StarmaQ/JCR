import 'package:flutter/material.dart';

class Tree {
  final String id;
  final String species;
  final double latitude;
  final double longitude;
  final int ageInMonths;
  final double heightInMeters;
  final double co2AbsorptionKgPerYear;
  final int humidityPercentage;
  final double temperatureEffect; // Reduction in surrounding temperature (°C)
  final String healthStatus;
  final DateTime plantedDate;

  Tree({
    required this.id,
    required this.species,
    required this.latitude,
    required this.longitude,
    required this.ageInMonths,
    required this.heightInMeters,
    required this.co2AbsorptionKgPerYear,
    required this.humidityPercentage,
    required this.temperatureEffect,
    required this.healthStatus,
    required this.plantedDate,
  });

  // Calculate the health indicator color based on the health status
  Color get healthColor {
    switch (healthStatus.toLowerCase()) {
      case 'excellent':
        return Colors.green.shade700;
      case 'good':
        return Colors.green.shade500;
      case 'fair':
        return Colors.yellow.shade700;
      case 'poor':
        return Colors.orange;
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Calculate the approximate CO2 absorbed so far
  double get totalCO2Absorbed {
    final yearsAlive = ageInMonths / 12;
    return co2AbsorptionKgPerYear * yearsAlive;
  }

  // Calculate the approximate water saved in liters
  double get waterRetention {
    // Simplified calculation: young trees retain less water
    final baseRetention = ageInMonths < 12 ? 50.0 : 100.0;
    return baseRetention * (humidityPercentage / 100) * (heightInMeters / 3);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'species': species,
      'latitude': latitude,
      'longitude': longitude,
      'ageInMonths': ageInMonths,
      'heightInMeters': heightInMeters,
      'co2AbsorptionKgPerYear': co2AbsorptionKgPerYear,
      'humidityPercentage': humidityPercentage,
      'temperatureEffect': temperatureEffect,
      'healthStatus': healthStatus,
      'plantedDate': plantedDate.toIso8601String(),
    };
  }

  factory Tree.fromMap(Map<String, dynamic> map) {
    return Tree(
      id: map['id'],
      species: map['species'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      ageInMonths: map['ageInMonths'],
      heightInMeters: map['heightInMeters'],
      co2AbsorptionKgPerYear: map['co2AbsorptionKgPerYear'],
      humidityPercentage: map['humidityPercentage'],
      temperatureEffect: map['temperatureEffect'],
      healthStatus: map['healthStatus'],
      plantedDate: DateTime.parse(map['plantedDate']),
    );
  }
} 