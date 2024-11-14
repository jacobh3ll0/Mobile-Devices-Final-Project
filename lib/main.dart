import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


// -- our packages -- //

//Authentication Handlers
import 'session_manager.dart';
import 'login_page/login_page.dart';

// page routes
import 'package:md_final/HomePage/home_page.dart';
import 'package:md_final/nutrition_page/nutrition_page.dart';
import 'package:md_final/profile_page/profile_page.dart';
import 'package:md_final/social_page/social_page.dart';
import 'package:md_final/workout_page/workout_page.dart';

// helper functions
import 'package:md_final/global_widgets/build_bottom_app_bar.dart';

// -----------------  //

void main() async
{
  WidgetsFlutterBinding.ensureInitialized(); //Ensures flutter binding initialized
  await Firebase.initializeApp(); //Initialize the firebase
  runApp(FitnessApp());
}

class FitnessApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness App', //Temp name, to be changed later
      home: AppLaunch(), //Launch the app
    );
  }
}

class AppLaunch extends StatefulWidget //Make the AppLaunch a stateful widget
{
  @override
  _AppLaunchState createState() => _AppLaunchState();
}

final storage = FlutterSecureStorage(); //Session token storage location

//AppLaunch Handles user session status (Has session token or no session token).
//If the session token exists, bring the user to home screen (using Home Navigator)
//If the session token does not exist, bring them to login/make an account
class _AppLaunchState extends State<AppLaunch>
{
  bool _isLoggedIn = false; //User not logged in by default

  //Session manager handles the tokens ...
  //Login creates a token, logout deletes the token, and isLoggedIn checks for a token
  final SessionManager _sessionManager = SessionManager(); //Create instance of session manager

  @override
  void initState() //In the initial state, check if the user is logged in
  {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async
  {
    bool isLoggedIn = await _sessionManager.isLoggedIn(); //Check for a current user token
    setState(()
    {
      _isLoggedIn = isLoggedIn; //Set the verdict of token found or not.
    });
  }

  Future<void> _logoutUser() async //Handles a user logout
  {
    await _sessionManager.logout(); //Session manager removes the session token
    setState(()
    {
      _isLoggedIn = false; //Sets the users logged in status to false
    });
  }

  Future<void> _loginUser(String token) async //Handles a successful login
  {
    await _sessionManager.login(token); //Adds the session token
    setState(()
    {
      _isLoggedIn = true; //Sets users logged in status to true
    });
  }

  @override
  Widget build(BuildContext context) //Build the widget based on the verdict of logged in status
  {
    //If the user is logged in, bring them to the HomeNavigator with logout functionality passed
    //Otherwise, bring them to login
    return _isLoggedIn ? HomeNavigator(logoutUser: _logoutUser) : LoginPage(loginUser: _loginUser);
    //HomeNavigator(logout) passes logout functionality to be used throughout the screens
    //Login(loginSuccess) passes login logic to login page.
  }
}

class HomeNavigator extends StatefulWidget
{
  final VoidCallback logoutUser; //Calls back to logout definition to remove user token and set login status to false.

  HomeNavigator({super.key, required this.logoutUser});

  @override
  State<HomeNavigator> createState() => _HomeNavigatorState();
}

class _HomeNavigatorState extends State<HomeNavigator> {
  int _currentPageIndex = 0;

  //list of pages
  late List<Widget> _pages = [
    HomePage(),
    NutritionPage(),
    WorkoutPage(),
    SocialPage(),
    ProfilePage(logoutCallback: widget.logoutUser), //Passes logout functionailty to profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BuildBottomNavigationBar(onTap: _onNavigationButtonTap, getIndex: _getCurrentSelectedIndex),
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