import 'package:flutter/material.dart';
import './models/notebook.dart';
import './provider/notebook_provider.dart';
import './views/splash_screen.dart';

void main() {
  runApp(
    NotebookProvider(
      notifier: ValueNotifier<List<Notebook>>([]),
      child: const MasterNotebookApp(),
    ),
  );
}

// Global Theme Controller
class ThemeController extends ChangeNotifier {
  static final ThemeController _instance = ThemeController._internal();
  factory ThemeController() => _instance;
  ThemeController._internal();

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class MasterNotebookApp extends StatefulWidget {
  const MasterNotebookApp({super.key});

  @override
  State<MasterNotebookApp> createState() => _MasterNotebookAppState();
}

class _MasterNotebookAppState extends State<MasterNotebookApp> {
  final ThemeController _themeController = ThemeController();

  @override
  void initState() {
    super.initState();
    _themeController.addListener(_updateTheme);
  }

  @override
  void dispose() {
    _themeController.removeListener(_updateTheme);
    super.dispose();
  }

  void _updateTheme() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Little Notebook',
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: _themeController.themeMode,
      home: const SplashScreen(),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6B4EE6), // Vibrant Purple
        brightness: Brightness.light,
        surface: const Color(0xFFF8F9FA),
        primary: const Color(0xFF6B4EE6),
        secondary: const Color(0xFF00C4CC), // Teal accent
      ),
      useMaterial3: true,
      fontFamily: 'Roboto', 
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF1A1C1E),
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF8B6FE6),
        brightness: Brightness.dark,
        surface: const Color(0xFF121418),
        background: const Color(0xFF0A0C10),
        primary: const Color(0xFF8B6FE6),
        secondary: const Color(0xFF00E5FF),
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF0A0C10),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
