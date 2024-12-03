import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../forgot_password_page/forgot_password_page.dart';
import '../signup_page/signup_page.dart';
import 'package:permission_handler/permission_handler.dart';  // Import to request permissions (Android 13+)
import 'dart:io' show Platform;

class LoginPage extends StatefulWidget //Handles user authentication (login) using FireBase - W/ Redirects for forgot password and signup
    {
  final Function(String) loginUser; //Get function to handle successful login during app launch
  const LoginPage({super.key, required this.loginUser});

  @override
  LoginPageState createState() => LoginPageState();

}

  class LoginPageState extends State<LoginPage> {
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

  void _initializeNotifications() async
  {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
  }

    Future<bool> verifyAccount(String email) async //Function to make sure that the user account contains all required information
    {
      try
      {
        final querySnapshot = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: email).get();

        if (querySnapshot.docs.isEmpty)
        {
          return false;
        }

        final userDoc = querySnapshot.docs.first;
        final userData = userDoc.data();

        final isValid = userData['displayName']?.isNotEmpty == true &&
            userData['email']?.isNotEmpty == true &&
            userData['gender']?.isNotEmpty == true &&
            userData['gymExperience']?.isNotEmpty == true;

        return isValid; //return true if all fields are found
      }
      catch (e)
      {
        return false; //Return false if an error occurs
      }
    }

  Future<void> _login(BuildContext context, String email, String password) async //Handles login attempt
  {
    try
    {
      //Attempt to sign on given inputted user email and password
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email.toLowerCase(), password: password);

      if(await verifyAccount(email.toLowerCase())) //Make sure the account contains all the required details. (Errors can arise if you close app during account creation)
        {
          String? token = await userCredential.user!.getIdToken(); //Retrieve the ID token for the user
          widget.loginUser(token!); //Pass the token back to AppLaunch to login the user
          _sendNotification("Login Successful", "Welcome back, $email!");
        }
      else
        {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your account contains errors ... Contact the application developer'), //Error message
              backgroundColor: Colors.red, //Set color red
            ),
          );
        }
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
  void initState() {
    super.initState();
    // Request notification permission if running on Android 13+
    if (Platform.isAndroid) {
      _requestNotificationPermission();
    }
    _initializeNotifications();
  }

    // Method to request notification permission on Android 13 and above
    Future<void> _requestNotificationPermission() async {
      if (Platform.isAndroid) {
        // Check if notification permission is denied
        if (await Permission.notification.isDenied) {
          // Request notification permission from the user
          PermissionStatus status = await Permission.notification.request();
          if (status.isDenied) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Notification Permissions Denied!"),
                backgroundColor: Colors.red,
              ),
            );
          } else if (status.isGranted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Notification Permissions Granted!"),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    }



  @override
  Widget build(BuildContext context) //Defines the login page
  {
    return Scaffold(
      appBar: AppBar(title: const Text("Fitness Application Login"), automaticallyImplyLeading: false),
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
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.error), //If the image fails to load, show error icon.
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
                    decoration: const InputDecoration(
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

                  const SizedBox(height: 16), //Spacing for atheistic

                 //Handles password field
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
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


                  const SizedBox(height: 35),

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
                              const SnackBar(
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
                      child: const Text('Login'),
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
                  child: const Text(
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
                  child: const Text(
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