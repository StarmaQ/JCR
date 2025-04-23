import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'screens/dashboard_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/map_screen.dart';
import 'screens/university_summary_screen.dart';
import 'data/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io' as io show Platform;
import 'package:campus_green_space/services/label_service.dart';

// Import for web
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Special handling for web version
  if (kIsWeb) {
    // Simple database factory for web
    databaseFactory = databaseFactoryFfiWeb;
  } else {
    try {
      // Check if we're on a desktop platform
      final bool isDesktop = 
        io.Platform.isWindows || 
        io.Platform.isLinux || 
        io.Platform.isMacOS;
        
      if (isDesktop) {
        // Initialize FFI for desktop platforms
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
    } catch (e) {
      print('Platform detection error: $e');
    }
  }
  
  // Initialize the database
  try {
    await DatabaseHelper().database;
  } catch (e) {
    print('Database initialization error: $e');
    // If there's an error, we'll proceed with the app anyway
    // and rely on the error handling in the screens
  }
  
  runApp(const MyApp());

  // Initialize label polling (no notifications)
  final labelService = LabelService();
  labelService.startPolling();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Green Space',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const MapScreen(),
    const ProfileScreen(),
    const UniversitySummaryScreen(),
  ];

  // Listen for detected labels via ValueNotifier
  final _labelService = LabelService();

  @override
  void initState() {
    super.initState();
    _labelService.labelNotifier.addListener(_onLabelDetected);
  }

  void _onLabelDetected() {
    final label = _labelService.labelNotifier.value;
    if (label != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Detected: $label')),
      );
    }
  }

  @override
  void dispose() {
    _labelService.labelNotifier.removeListener(_onLabelDetected);
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'University',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 8,
      ),
    );
  }
}
