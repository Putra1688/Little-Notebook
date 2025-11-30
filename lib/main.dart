import 'package:flutter/material.dart';
import './models/notebook.dart';
import './provider/notebook_provider.dart';
import './views/splash_screen.dart';
import './themes/app_colors.dart';


void main() {
  runApp(
    NotebookProvider(
      notifier: ValueNotifier<List<Notebook>>([]),
      child: const MasterNotebookApp(),
    ),
  );
}

class MasterNotebookApp extends StatefulWidget {
  const MasterNotebookApp({super.key});

  @override
  State<MasterNotebookApp> createState() => _MasterNotebookAppState();
}

class _MasterNotebookAppState extends State<MasterNotebookApp> {
  @override
  void initState() {
    super.initState();
    _loadNotebooks();
  }

  void _loadNotebooks() async {
    // Notebooks loaded from storage automatically
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neural Notebook',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}