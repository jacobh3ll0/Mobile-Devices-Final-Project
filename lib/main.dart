import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// -- our packages -- //
import 'package:md_final/global_widgets/build_bottom_app_bar.dart';
import 'package:md_final/global_widgets/theme_related/theme_manager.dart';
import 'global_widgets/database_model.dart';

// Authentication Handlers
import 'session_manager.dart';
import 'login_page/login_page.dart';

// Page routes
import 'package:md_final/HomePage/home_page.dart';
import 'package:md_final/nutrition_page/nutrition_page.dart';
import 'package:md_final/profile_page/profile_page.dart';
import 'package:md_final/social_page/social_page.dart';
import 'package:md_final/workout_page/workout_page.dart';

// ----------------- //

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures flutter binding is initialized
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const FitnessApp());
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize database
    DatabaseModel();

    return MaterialApp(
      title: 'Fitness App', // Temp name, to be changed later
      theme: ThemeManager.getThemeData(),
      home: const _AppLaunch(), // Launch the app
    );
  }
}

class _AppLaunch extends StatefulWidget {
  const _AppLaunch({super.key});

  @override
  _AppLaunchState createState() => _AppLaunchState();
}

const storage = FlutterSecureStorage(); // Session token storage location

class _AppLaunchState extends State<_AppLaunch> {
  bool _isLoggedIn = false;

  final SessionManager _sessionManager = SessionManager(); // Create instance of session manager

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    bool isLoggedIn = await _sessionManager.isLoggedIn();
    setState(() {
      _isLoggedIn = isLoggedIn;
    });
  }

  Future<void> _logoutUser() async {
    await _sessionManager.logout();
    setState(() {
      _isLoggedIn = false;
    });
  }

  Future<void> _loginUser(String token) async {
    await _sessionManager.login(token);
    setState(() {
      _isLoggedIn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoggedIn
        ? HomeNavigator(logoutUser: _logoutUser)
        : LoginPage(loginUser: _loginUser);
  }
}

class HomeNavigator extends StatefulWidget {
  final VoidCallback logoutUser;

  const HomeNavigator({super.key, required this.logoutUser});

  @override
  State<HomeNavigator> createState() => _HomeNavigatorState();
}

class _HomeNavigatorState extends State<HomeNavigator> {
  int _currentPageIndex = 0;

  // List of pages
  late final List<Widget> _pages = [
    const HomePage(),
    const NutritionPage(), // NutritionPage now matches their structure
    const WorkoutPage(),
    const SocialPage(),
    ProfilePage(logoutCallback: widget.logoutUser), // Passes logout functionality to profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BuildBottomNavigationBar(
        onTap: _onNavigationButtonTap,
        getIndex: _getCurrentSelectedIndex,
      ),
      body: IndexedStack(
        index: _currentPageIndex,
        children: _pages,
      ),
    );
  }

  void _onNavigationButtonTap(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  int _getCurrentSelectedIndex() {
    return _currentPageIndex;
  }
}
