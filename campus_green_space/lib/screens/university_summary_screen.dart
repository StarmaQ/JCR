import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../data/database_helper.dart';
import '../models/student.dart';

class UniversitySummaryScreen extends StatefulWidget {
  const UniversitySummaryScreen({super.key});

  @override
  State<UniversitySummaryScreen> createState() => _UniversitySummaryScreenState();
}

class _UniversitySummaryScreenState extends State<UniversitySummaryScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  late Future<Map<String, dynamic>> _universityStatsFuture;
  late Future<List<Student>> _topStudentsFuture;
  late Future<Map<String, dynamic>> _predictionFuture;

  @override
  void initState() {
    super.initState();
    _universityStatsFuture = _databaseHelper.getUniversityStats();
    _topStudentsFuture = _databaseHelper.getTopStudents(limit: 5);
    _predictionFuture = _databaseHelper.getUniversityAnnualPrediction();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('University Environmental Impact'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentStats(),
            const SizedBox(height: 24),
            _buildLeaderboard(),
            const SizedBox(height: 24),
            _buildPredictions(),
            const SizedBox(height: 24),
            _buildCO2SavingsChart(),
            const SizedBox(height: 24),
            _buildGlobalInitiatives(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStats() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _universityStatsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(child: Text('Error: ${snapshot.error}')),
            ),
          );
        }

        final stats = snapshot.data!;
        final formatter = NumberFormat('#,###');

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Statistics',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                      'CO₂ Saved',
                      '${formatter.format(stats['totalCO2Reduced'])} kg',
                      Icons.eco,
                      Colors.green,
                    ),
                    _buildStatCard(
                      'Water Saved',
                      '${formatter.format(stats['totalWaterSaved'])} gal',
                      Icons.water_drop,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      'Carbon Points',
                      formatter.format(stats['totalCarbonPoints']),
                      Icons.star,
                      Colors.amber,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                      'Trees Planted',
                      formatter.format(stats['totalTreesPlanted']),
                      Icons.park,
                      Colors.green.shade800,
                    ),
                    _buildStatCard(
                      'Solar Panels',
                      formatter.format(stats['totalSolarPanelsInstalled']),
                      Icons.solar_power,
                      Colors.orange,
                    ),
                    _buildStatCard(
                      'Participants',
                      formatter.format(stats['totalStudents']),
                      Icons.people,
                      Colors.indigo,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboard() {
    return FutureBuilder<List<Student>>(
      future: _topStudentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(child: Text('Error: ${snapshot.error}')),
            ),
          );
        }

        final topStudents = snapshot.data!;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Top Environmental Champions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...topStudents.asMap().entries.map((entry) {
                  final index = entry.key;
                  final student = entry.value;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getRankColor(index),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(student.name),
                    subtitle: Text('ID: ${student.universityId}'),
                    trailing: Text(
                      '${student.carbonPoints} pts',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber;
      case 1:
        return Colors.grey;
      case 2:
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }

  Widget _buildPredictions() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _predictionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(child: Text('Error: ${snapshot.error}')),
            ),
          );
        }
        final preds = snapshot.data!;
        final formatter = NumberFormat('#,###');
        final currentCo2 = formatter.format(preds['currentAnnualCO2']);
        final predictedCo2 = formatter.format(preds['predictedAnnualCO2']);
        final pctCo2 = preds['percentageCo2Change'] as double;
        final currentWater = formatter.format(preds['currentAnnualWater']);
        final predictedWater = formatter.format(preds['predictedAnnualWater']);
        final pctWater = preds['percentageWaterChange'] as double;
        final currentCarbon = formatter.format(preds['currentAnnualCarbonPoints']);
        final predictedCarbon = formatter.format(preds['predictedAnnualCarbonPoints']);
        final pctCarbon = preds['percentageCarbonChange'] as double;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Environmental Impact Forecast',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildPredictionItem(
                  'CO₂ Reduction',
                  'Current: $currentCo2 kg',
                  'Next Year: $predictedCo2 kg',
                  '+${pctCo2.toStringAsFixed(1)}%',
                  Colors.green,
                ),
                const SizedBox(height: 12),
                _buildPredictionItem(
                  'Water Usage',
                  'Current: $currentWater gal',
                  'Next Year: $predictedWater gal',
                  '+${pctWater.toStringAsFixed(1)}%',
                  Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildPredictionItem(
                  'Carbon Points',
                  'Current: $currentCarbon',
                  'Next Year: $predictedCarbon',
                  '+${pctCarbon.toStringAsFixed(1)}%',
                  Colors.amber,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPredictionItem(
    String title,
    String current,
    String nextYear,
    String percentage,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(current),
            Text(
              percentage,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          nextYear,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCO2SavingsChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CO₂ Savings Trend',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                          if (value.toInt() >= 0 && value.toInt() < months.length) {
                            return Text(months[value.toInt()]);
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 1.5),
                        FlSpot(1, 1.8),
                        FlSpot(2, 2.1),
                        FlSpot(3, 2.3),
                        FlSpot(4, 2.4),
                        FlSpot(5, 2.5),
                      ],
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalInitiatives() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'University-Wide Initiatives',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.park, color: Colors.green),
              title: Text('Campus Trees Planted: ${_databaseHelper.totalTreesPlanted}'),
              subtitle: const Text('Contributing to carbon offset and campus beautification'),
            ),
            ListTile(
              leading: const Icon(Icons.solar_power, color: Colors.orange),
              title: Text('Solar Panels Installed: ${_databaseHelper.totalSolarPanelsInstalled}'),
              subtitle: const Text('Reducing campus carbon footprint by generating clean energy'),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'These university-wide initiatives are part of our commitment to sustainability and environmental responsibility.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 