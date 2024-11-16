import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../forgot_password_page/forgot_password_page.dart';
import '../signup_page/signup_page.dart';

class LoginPage extends StatefulWidget //Handles user authentication (login) using FireBase - W/ Redirects for forgot password and signup
    {
  final Function(String) loginUser; //Get function to handle successful login during app launch
  LoginPage({required this.loginUser});

  @override
  _LoginPageState createState() => _LoginPageState();

}

  class _LoginPageState extends State<LoginPage> {
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();


  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  // Method to send notifications
  Future<void> _sendNotification(String title, String body) async {
    // Notification details for Android platform
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'auth_channel', 'Authentication Notifications',
      channelDescription: 'Notifications for authentication actions',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    // Show the notification
    await _notificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _login(BuildContext context, String email, String password) async //Handles login attempt
  {
    try
    {
      //Attempt to sign on given inputted user email and password
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email.toLowerCase(), password: password);
      String? token = await userCredential.user!.getIdToken(); //Retrieve the ID token for the user
      widget.loginUser(token!); //Pass the token back to AppLaunch to login the user

      _sendNotification("Login Successful", "Welcome back, $email!");
    }
    catch (e) //If the database fails to find the users information, output the error in snackbar
    {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: $e'), //We could change this to be less descriptive later. Maybe just login failed.
          backgroundColor: Colors.red, //Set snackbar color
        ),
      );
    }
  }

  @override
  void initState(){
    super.initState();
    _initializeNotifications();
  }

  @override
  Widget build(BuildContext context) //Defines the login page
  {
    return Scaffold(
      appBar: AppBar(title: Text("Fitness Application Login"), automaticallyImplyLeading: false),
      body: Column(
        children: [

          //Handles the image format at the top
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Image.network(
                //Some random image I found online (Copyright free)
                'https://img.freepik.com/premium-vector/vintage-fitness-logotype-with-strong-man-hand-holding-fiery-dumbbell_153969-6.jpg?w=740',
                fit: BoxFit.contain, //Fit image within padding constraints
                errorBuilder: (context, error, stackTrace) => Icon(Icons.error), //If the image fails to load, show error icon.
              ),
            ),
          ),

          //Handles the login detail format
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  //Handles username field
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey, // Color of the underline when not focused
                          width: 1.0,         // Thickness of the underline
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.purple, // Color of the underline when focused
                          width: 2.0,         // Thickness of the underline when focused
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16), //Spacing for atheistics

                 //Handles password field
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey, // Color of the underline when not focused
                          width: 1.0,         // Thickness of the underline
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.purple, // Color of the underline when focused
                          width: 2.0,         // Thickness of the underline when focused
                        ),
                      ),
                    ),
                  ),


                  SizedBox(height: 35),

                  //Defines the login button
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: ()
                      {
                        if(_emailController.text != "" && _passwordController.text != "")
                        {
                          _login(context, _emailController.text, _passwordController.text);
                        }
                        else
                          {
                            ScaffoldMessenger.of(context)
                                .showSnackBar( //Output error
                              SnackBar(
                                content: Text('You must input and email and a password!'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                      }, //Attempt login with given details
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple, //Set background colour
                        foregroundColor: Colors.white, //Set text colour
                      ),
                      child: Text('Login'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          //Defines Forgot Password and Sign Up text buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, //Space them apart (For each corner)
              children: [

                //(Left side) Defines forgot password button
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ForgotPasswordPage()), //Send to forgot password form
                    );
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(decoration: TextDecoration.none),
                  ),
                ),

                //(Right Side) Defines signup button
                TextButton(
                  onPressed: ()
                  {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpPage()), //Send to sign up form
                    );
                  },
                  child: Text(
                    'Sign Up',
                    style: TextStyle(decoration: TextDecoration.none),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}