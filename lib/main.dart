import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/worker/worker_home_page.dart';
import 'pages/boss/boss_home_page.dart';
import 'models/worker_data.dart';
import 'models/worker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Check for command line arguments
  const userType = String.fromEnvironment('USER_TYPE', defaultValue: '');
  const username = String.fromEnvironment('USERNAME', defaultValue: '');
  const password = String.fromEnvironment('PASSWORD', defaultValue: '');
  
  final prefs = await SharedPreferences.getInstance();
  final darkMode = prefs.getBool('darkMode') ?? false;
  
  // If user type is provided via command line, skip login page
  if (userType.isNotEmpty) {
    if (userType == 'boss') {
      runApp(MyApp(
        initialDarkMode: darkMode,
        initialPage: const BossHomePage(),
      ));
    } else if (userType == 'worker' && username.isNotEmpty) {
      Worker? worker = WorkerData.login(username, password, 'worker');
      if (worker != null) {
        runApp(MyApp(
          initialDarkMode: darkMode,
          initialPage: WorkerHomePage(worker: worker),
        ));
      } else {
        runApp(MyApp(
          initialDarkMode: darkMode,
          initialPage: const LoginPage(),
        ));
      }
    } else {
      runApp(MyApp(
        initialDarkMode: darkMode,
        initialPage: const LoginPage(),
      ));
    }
  } else {
    runApp(MyApp(
      initialDarkMode: darkMode,
      initialPage: const LoginPage(),
    ));
  }
}

class MyApp extends StatefulWidget {
  final bool initialDarkMode;
  final Widget initialPage;

  const MyApp({
    super.key, 
    required this.initialDarkMode,
    required this.initialPage,
  });

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MyAppState>();
  }
}

class _MyAppState extends State<MyApp> {
  late bool _darkMode;
  late Widget _currentPage;

  @override
  void initState() {
    super.initState();
    _darkMode = widget.initialDarkMode;
    _currentPage = widget.initialPage;
  }

  void toggleTheme(bool isDark) {
    setState(() {
      _darkMode = isDark;
    });
  }

  void navigateTo(Widget page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Worker Salary Calculator',
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 0,
        ),
      ),
      home: _currentPage,
      debugShowCheckedModeBanner: false,
    );
  }
}