import 'package:flutter/material.dart';

class Bin {
  final int? id;
  final String name;
  final double latitude;
  final double longitude;
  final double fillLevel; // 0-100%
  final String type; // recycling, trash, compost
  final DateTime lastUpdated;

  Bin({
    this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.fillLevel,
    required this.type,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'fill_level': fillLevel,
      'type': type,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  factory Bin.fromMap(Map<String, dynamic> map) {
    return Bin(
      id: map['id'],
      name: map['name'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      fillLevel: map['fill_level'],
      type: map['type'],
      lastUpdated: DateTime.parse(map['last_updated']),
    );
  }

  Color get fillColor {
    if (fillLevel < 30) return const Color(0xFF4CAF50); // Green
    if (fillLevel < 70) return const Color(0xFFFF9800); // Orange
    return const Color(0xFFF44336); // Red
  }

  String get fillStatus {
    if (fillLevel < 30) return 'Empty';
    if (fillLevel < 70) return 'Half Full';
    return 'Full';
  }
} 