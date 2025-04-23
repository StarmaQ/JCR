import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../models/bin.dart';
import '../models/tree.dart';
import 'dart:math';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  Position? currentPosition;
  final List<Marker> markers = [];
  bool _isLoading = true;
  bool _showTrees = true;
  bool _showBins = true;

  // INSAT's precise coordinates
  static const LatLng insatCenter = LatLng(36.842981965232426, 10.196795594448318);

  // Mock data for bins at INSAT with realistic positions
  final List<Bin> bins = [
    Bin(
      name: 'Main Entrance Bin',
      latitude: 36.84345,
      longitude: 10.19640,
      fillLevel: 45,
      type: 'recycling',
    ),
    Bin(
      name: 'Cafeteria Bin',
      latitude: 36.84280,
      longitude: 10.19690,
      fillLevel: 80,
      type: 'trash',
    ),
    Bin(
      name: 'Library Entrance Bin',
      latitude: 36.84315,
      longitude: 10.19720,
      fillLevel: 20,
      type: 'recycling',
    ),
    Bin(
      name: 'Department Block A Bin',
      latitude: 36.84260,
      longitude: 10.19670,
      fillLevel: 60,
      type: 'trash',
    ),
    Bin(
      name: 'Sports Area Bin',
      latitude: 36.84220,
      longitude: 10.19710,
      fillLevel: 30,
      type: 'recycling',
    ),
    Bin(
      name: 'Parking Area Bin',
      latitude: 36.84330,
      longitude: 10.19590,
      fillLevel: 40,
      type: 'trash',
    ),
    Bin(
      name: 'Student Center Bin',
      latitude: 36.84290,
      longitude: 10.19650,
      fillLevel: 55,
      type: 'recycling',
    ),
  ];
  
  // Mock data for trees at INSAT with coordinates in the "zone verte" (green zone)
  final List<Tree> trees = [
    Tree(
      id: 'tree1',
      species: 'Olive Tree (Zeitoun)',
      latitude: 36.84210,
      longitude: 10.19580, 
      ageInMonths: 72,
      heightInMeters: 3.5,
      co2AbsorptionKgPerYear: 22.5,
      humidityPercentage: 62,
      temperatureEffect: 1.2,
      healthStatus: 'excellent',
      plantedDate: DateTime(2017, 3, 15),
    ),
    Tree(
      id: 'tree2',
      species: 'Aleppo Pine (Snouber)',
      latitude: 36.84225,
      longitude: 10.19600,
      ageInMonths: 108,
      heightInMeters: 6.5,
      co2AbsorptionKgPerYear: 48.0,
      humidityPercentage: 58,
      temperatureEffect: 2.8,
      healthStatus: 'good',
      plantedDate: DateTime(2014, 4, 22),
    ),
    Tree(
      id: 'tree3',
      species: 'Carob Tree (Kharroub)',
      latitude: 36.84235,
      longitude: 10.19560,
      ageInMonths: 132,
      heightInMeters: 5.2,
      co2AbsorptionKgPerYear: 35.0,
      humidityPercentage: 65,
      temperatureEffect: 2.1,
      healthStatus: 'fair',
      plantedDate: DateTime(2012, 3, 12),
    ),
    Tree(
      id: 'tree4',
      species: 'Eucalyptus (Kalitus)',
      latitude: 36.84250,
      longitude: 10.19595,
      ageInMonths: 84,
      heightInMeters: 8.5,
      co2AbsorptionKgPerYear: 52.0,
      humidityPercentage: 72,
      temperatureEffect: 3.2,
      healthStatus: 'excellent',
      plantedDate: DateTime(2016, 9, 5),
    ),
    Tree(
      id: 'tree5',
      species: 'Citrus (Lim)',
      latitude: 36.84200,
      longitude: 10.19560,
      ageInMonths: 48,
      heightInMeters: 2.4,
      co2AbsorptionKgPerYear: 15.0,
      humidityPercentage: 60,
      temperatureEffect: 0.8,
      healthStatus: 'good',
      plantedDate: DateTime(2020, 2, 12),
    ),
    Tree(
      id: 'tree6',
      species: 'Date Palm (Nakhla)',
      latitude: 36.84215,
      longitude: 10.19615,
      ageInMonths: 144,
      heightInMeters: 7.8,
      co2AbsorptionKgPerYear: 38.0,
      humidityPercentage: 55,
      temperatureEffect: 2.5,
      healthStatus: 'good',
      plantedDate: DateTime(2011, 5, 8),
    ),
    Tree(
      id: 'tree7',
      species: 'Cypress (Sarwal)',
      latitude: 36.84240,
      longitude: 10.19625,
      ageInMonths: 156,
      heightInMeters: 9.2,
      co2AbsorptionKgPerYear: 45.0,
      humidityPercentage: 50,
      temperatureEffect: 2.2,
      healthStatus: 'excellent',
      plantedDate: DateTime(2010, 1, 20),
    ),
    Tree(
      id: 'tree8',
      species: 'Barbary Fig (Karmus Hindi)',
      latitude: 36.84195,
      longitude: 10.19590,
      ageInMonths: 60,
      heightInMeters: 1.8,
      co2AbsorptionKgPerYear: 10.0,
      humidityPercentage: 75,
      temperatureEffect: 0.6,
      healthStatus: 'good',
      plantedDate: DateTime(2019, 8, 15),
    ),
    Tree(
      id: 'tree9',
      species: 'Acacia (Sant)',
      latitude: 36.84180,
      longitude: 10.19570,
      ageInMonths: 96,
      heightInMeters: 4.5,
      co2AbsorptionKgPerYear: 28.0,
      humidityPercentage: 45,
      temperatureEffect: 1.8,
      healthStatus: 'fair',
      plantedDate: DateTime(2015, 6, 10),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait([
      _getCurrentLocation(),
      Future.delayed(const Duration(milliseconds: 500)),
    ]);
    _updateMarkers();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        currentPosition = position;
      });
    }
  }

  void _updateMarkers() {
    markers.clear();
    if (_showBins) {
      for (var bin in bins) {
        markers.add(_createBinMarker(bin));
      }
    }
    if (_showTrees) {
      for (var tree in trees) {
        markers.add(_createTreeMarker(tree));
      }
    }
  }

  Marker _createBinMarker(Bin bin) {
    return Marker(
      point: LatLng(bin.latitude, bin.longitude),
      width: 30.0,
      height: 30.0,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.delete,
            color: bin.fillColor,
            size: 30.0,
          ),
          Positioned(
            bottom: 2.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 0.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 1.0,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                '${bin.fillLevel}%',
                style: const TextStyle(
                  fontSize: 8.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Marker _createTreeMarker(Tree tree) {
    return Marker(
      point: LatLng(tree.latitude, tree.longitude),
      width: 40.0,
      height: 40.0,
      child: GestureDetector(
        onTap: () => _showTreeDetails(tree),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.park,
              color: tree.healthColor,
              size: min(40.0, 20.0 + tree.heightInMeters),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 1.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 1.0,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  '${tree.humidityPercentage}% 💧',
                  style: const TextStyle(
                    fontSize: 8.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTreeDetails(Tree tree) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.park, color: tree.healthColor),
            const SizedBox(width: 8),
            Text(tree.species),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTreeStat('Age', '${(tree.ageInMonths / 12).toStringAsFixed(1)} years'),
            _buildTreeStat('Height', '${tree.heightInMeters} meters'),
            _buildTreeStat('Health', tree.healthStatus),
            _buildTreeStat('Humidity', '${tree.humidityPercentage}%'),
            _buildTreeStat('Temperature Effect', '-${tree.temperatureEffect}°C nearby'),
            _buildTreeStat('CO₂ Absorption', '${tree.co2AbsorptionKgPerYear} kg/year'),
            _buildTreeStat('Total CO₂ Absorbed', '${tree.totalCO2Absorbed.toStringAsFixed(1)} kg'),
            _buildTreeStat('Water Retention', '${tree.waterRetention.toStringAsFixed(1)} liters'),
            _buildTreeStat('Planted Date', '${tree.plantedDate.day}/${tree.plantedDate.month}/${tree.plantedDate.year}'),
            
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: tree.humidityPercentage / 100,
              backgroundColor: Colors.blue.shade100,
              color: Colors.blue,
            ),
            const SizedBox(height: 4),
            const Text('Humidity Level', style: TextStyle(fontSize: 10)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildTreeStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading map...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Green Map'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.park,
              color: _showTrees ? Colors.green : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _showTrees = !_showTrees;
                _updateMarkers();
              });
            },
            tooltip: 'Show/Hide Trees',
          ),
          IconButton(
            icon: Icon(
              Icons.delete,
              color: _showBins ? Colors.blue : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _showBins = !_showBins;
                _updateMarkers();
              });
            },
            tooltip: 'Show/Hide Bins',
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: insatCenter,
              zoom: 17.5,
              onTap: (_, __) => {},
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.campus_green_space',
                maxZoom: 19,
                minZoom: 15,
              ),
              MarkerLayer(
                markers: markers,
              ),
              if (currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        currentPosition!.latitude,
                        currentPosition!.longitude,
                      ),
                      width: 30,
                      height: 30,
                      child: const Icon(
                        Icons.person_pin_circle,
                        color: Colors.blue,
                        size: 30,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (_showTrees)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: _buildTreesSummaryCard(),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              _mapController.move(insatCenter, 17.5);
            },
            child: const Icon(Icons.center_focus_strong),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              _updateMarkers();
              setState(() {});
            },
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }

  Widget _buildTreesSummaryCard() {
    // Calculate total environmental impact
    final totalCO2 = trees.fold(0.0, (sum, tree) => sum + tree.totalCO2Absorbed);
    final averageHumidity = trees.fold(0, (sum, tree) => sum + tree.humidityPercentage) / trees.length;
    final totalWaterRetention = trees.fold(0.0, (sum, tree) => sum + tree.waterRetention);
    final totalTempEffect = trees.fold(0.0, (sum, tree) => sum + tree.temperatureEffect);
    
    return Card(
      elevation: 4,
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Environmental Impact',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryMetric(
                  icon: Icons.eco,
                  value: '${totalCO2.toStringAsFixed(1)} kg',
                  label: 'CO₂ Absorbed',
                  color: Colors.green,
                ),
                _buildSummaryMetric(
                  icon: Icons.water_drop,
                  value: '${averageHumidity.toStringAsFixed(0)}%',
                  label: 'Avg Humidity',
                  color: Colors.blue,
                ),
                _buildSummaryMetric(
                  icon: Icons.thermostat,
                  value: '-${totalTempEffect.toStringAsFixed(1)}°C',
                  label: 'Temp Effect',
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Trees: ${trees.length}'),
                Text('Water retained: ${totalWaterRetention.toStringAsFixed(0)} liters'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryMetric({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
} 