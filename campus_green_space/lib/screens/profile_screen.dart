import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/database_helper.dart';
import '../models/student.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  late Future<Map<String, dynamic>> _profileDataFuture;

  @override
  void initState() {
    super.initState();
    // Load Mohamed's data and calculate his rank
    _profileDataFuture = _loadProfileData();
  }

  Future<Map<String, dynamic>> _loadProfileData() async {
    // Get all students and sort them by carbon points
    final allStudents = await _databaseHelper.getStudents();
    allStudents.sort((a, b) => b.carbonPoints.compareTo(a.carbonPoints));
    
    // Find Mohamed's position in the sorted list
    final mohamed = await _databaseHelper.getStudentByName('Mohamed Maatoug');
    
    int rank = 0;
    if (mohamed != null) {
      // Find Mohamed's rank (1-based index)
      rank = allStudents.indexWhere((s) => s.id == mohamed.id) + 1;
    } else {
      // If Mohamed isn't found, use the first student
      if (allStudents.isNotEmpty) {
        rank = 1;
      }
    }
    
    // Calculate percentile - higher is better
    double percentile = 0;
    if (allStudents.isNotEmpty && rank > 0) {
      percentile = ((allStudents.length - rank) / allStudents.length) * 100;
    }
    
    // Return both the student data and the calculated rank
    return {
      'student': mohamed ?? (allStudents.isNotEmpty ? allStudents[0] : null),
      'rank': rank,
      'totalStudents': allStudents.length,
      'percentile': percentile.round()
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _profileDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data;
        final student = data?['student'] as Student?;
        final rank = data?['rank'] ?? 0;
        final totalStudents = data?['totalStudents'] ?? 0;
        final percentile = data?['percentile'] ?? 0;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text('Mohamed Maatoug'),
                  centerTitle: true,
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.green.shade800,
                          Colors.green.shade600,
                        ],
                      ),
                    ),
                    child: const Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage: AssetImage('assets/images/pfp.jpg'),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStudentInfo(student),
                      const SizedBox(height: 24),
                      _buildPointsCard(student, rank, totalStudents, percentile),
                      const SizedBox(height: 24),
                      _buildAchievements(),
                      const SizedBox(height: 24),
                      _buildEnvironmentalImpact(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStudentInfo(Student? student) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Student Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Name', 'Mohamed Maatoug'),
            _buildInfoRow('Student ID', student?.universityId ?? 'Loading...'),
            _buildInfoRow('Join Date', 'September 2023'),
            _buildInfoRow('University', 'Green University of Sciences'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsCard(Student? student, int rank, int totalStudents, int percentile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Environmental Points',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPointsStat(
                  'Total Points', 
                  '${student?.carbonPoints ?? 0}', 
                  Icons.star
                ),
                _buildPointsStat(
                  'Rank', 
                  '$rank of $totalStudents', 
                  Icons.emoji_events
                ),
                _buildPercentileStat(
                  'Percentile', 
                  '$percentile%', 
                  Icons.trending_up,
                  'You\'re outperforming $percentile% of students in environmental impact'
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.green),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildPercentileStat(String label, String value, IconData icon, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Column(
        children: [
          Icon(icon, size: 32, color: Colors.green),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Achievements',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildAchievementItem(
              'Environmental Champion',
              'Top contributor for 3 months',
              Icons.emoji_events,
              Colors.amber,
            ),
            _buildAchievementItem(
              'Recycling Master',
              'Recycled 100+ items',
              Icons.recycling,
              Colors.blue,
            ),
            _buildAchievementItem(
              'CO₂ Warrior',
              'Reduced 500kg of CO₂',
              Icons.eco,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementItem(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text(description),
      trailing: const Icon(Icons.check_circle, color: Colors.green),
    );
  }

  Widget _buildEnvironmentalImpact() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Environmental Impact',
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
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                          if (value.toInt() >= 0 && value.toInt() < months.length) {
                            // Create a widget with month name and a small day indicator
                            return Column(
                              children: [
                                Text(
                                  months[value.toInt()],
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  '${(value.toInt() * 15) + 1}', // Display a day number for each month (simulated)
                                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                                ),
                              ],
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
                      spots: const [
                        FlSpot(0, 200),
                        FlSpot(1, 350),
                        FlSpot(2, 500),
                        FlSpot(3, 750),
                        FlSpot(4, 900),
                        FlSpot(5, 1250),
                        FlSpot(6, 1500),
                        FlSpot(7, 1800),
                        FlSpot(8, 2100),
                        FlSpot(9, 2400),
                        FlSpot(10, 2700),
                        FlSpot(11, 3000),
                      ],
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 5,
                            color: Colors.green,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withOpacity(0.1),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.white,
                      tooltipBorder: const BorderSide(color: Colors.green),
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        const months = ['January', 'February', 'March', 'April', 'May', 'June', 
                                      'July', 'August', 'September', 'October', 'November', 'December'];
                        
                        return touchedSpots.map((LineBarSpot touchedSpot) {
                          final index = touchedSpot.x.toInt();
                          final month = index >= 0 && index < months.length ? months[index] : '';
                          final day = (index * 15) + 1; // Simulated day for each month point
                          
                          return LineTooltipItem(
                            '$month $day: ${touchedSpot.y.toInt()} pts',
                            const TextStyle(
                              color: Colors.green,
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
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Yearly Progress & Predictions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildProgressStat('Current', '1,250 pts', '+150%', Colors.green),
                  _buildProgressStat('Target', '3,000 pts', 'by Dec 2024', Colors.blue),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildImpactStat('CO₂ Saved', '250 kg', Icons.eco, '+45% vs last year'),
                _buildImpactStat('Items Recycled', '120', Icons.recycling, '+30% vs last year'),
                _buildImpactStat('Bins Used', '85', Icons.delete, '+25% vs last year'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStat(String label, String value, String subValue, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          subValue,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildImpactStat(String label, String value, IconData icon, String subValue) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.green),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        Text(
          subValue,
          style: const TextStyle(
            color: Colors.green,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
} 