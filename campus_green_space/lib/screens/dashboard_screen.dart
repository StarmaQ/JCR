import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Green Space'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bluetooth),
            onPressed: () {
              // TODO: Navigate to BLE connection screen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Environmental Impact Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Environmental Impact',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        _getTodayDate(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetricCard(
                          'Trash',
                          '0.5 kg',
                          Icons.delete,
                          Colors.orange,
                        ),
                        _buildMetricCard(
                          'Electricity',
                          '2.3 kWh',
                          Icons.electric_bolt,
                          Colors.blue,
                        ),
                        _buildMetricCard(
                          'CO2',
                          '1.2 kg',
                          Icons.cloud,
                          Colors.green,
                        ),
                        _buildMetricCard(
                          'Recycling',
                          '75%',
                          Icons.recycling,
                          Colors.purple,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Weekly Progress Charts
            _buildChartCard(
              'Trash Collection',
              Colors.orange,
              [
                const FlSpot(0, 0.5),
                const FlSpot(1, 0.8),
                const FlSpot(2, 0.6),
                const FlSpot(3, 0.9),
                const FlSpot(4, 0.7),
                const FlSpot(5, 0.5),
                const FlSpot(6, 0.4),
              ],
            ),
            const SizedBox(height: 16),
            _buildChartCard(
              'Electricity Usage',
              Colors.blue,
              [
                const FlSpot(0, 2.3),
                const FlSpot(1, 2.1),
                const FlSpot(2, 2.5),
                const FlSpot(3, 2.0),
                const FlSpot(4, 2.2),
                const FlSpot(5, 2.4),
                const FlSpot(6, 2.1),
              ],
            ),
            const SizedBox(height: 16),
            _buildChartCard(
              'CO2 Emissions',
              Colors.green,
              [
                const FlSpot(0, 1.2),
                const FlSpot(1, 1.0),
                const FlSpot(2, 1.3),
                const FlSpot(3, 1.1),
                const FlSpot(4, 1.2),
                const FlSpot(5, 1.0),
                const FlSpot(6, 0.9),
              ],
            ),
            const SizedBox(height: 16),
            _buildChartCard(
              'Recycling Rate',
              Colors.purple,
              [
                const FlSpot(0, 75),
                const FlSpot(1, 80),
                const FlSpot(2, 78),
                const FlSpot(3, 82),
                const FlSpot(4, 85),
                const FlSpot(5, 88),
                const FlSpot(6, 90),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildChartCard(String title, Color color, List<FlSpot> spots) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
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
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < days.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                days[index],
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: false,
                      color: color,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) => 
                          FlDotCirclePainter(
                            radius: 5,
                            color: color,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withOpacity(0.1),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.white,
                      tooltipBorder: BorderSide(color: color),
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((LineBarSpot touchedSpot) {
                          final index = touchedSpot.x.toInt();
                          final day = index >= 0 && index < days.length 
                              ? days[index] 
                              : '';
                          return LineTooltipItem(
                            '$day: ${touchedSpot.y.toStringAsFixed(1)}',
                            TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to get today's date in a nice format
  String _getTodayDate() {
    final now = DateTime.now();
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 
                   'August', 'September', 'October', 'November', 'December'];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }
} 