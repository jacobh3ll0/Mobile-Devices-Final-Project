import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../forgot_password_page/forgot_password_page.dart';
import '../signup_page/signup_page.dart';

class LoginPage extends StatelessWidget //Handles user authentication (login) using FireBase - W/ Redirects for forgot password and signup
{
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final Function(String) loginUser; //Get function to handle successful login during app launch
  LoginPage({required this.loginUser});

  Future<void> _login(BuildContext context, String email, String password) async //Handles login attempt
  {
    try
    {
      //Attempt to sign on given inputted user email and password
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      String? token = await userCredential.user!.getIdToken(); //Retrieve the ID token for the user
      loginUser(token!); //Pass the token back to AppLaunch to login the user
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
                      border: OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(height: 16), //Spacing for atheistics

                 //Handles password field
                  TextField(
                    controller: _passwordController,
                    obscureText: true, //Obscure the password text
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 35),

                  //Defines the login button
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _login(context, _emailController.text, _passwordController.text), //Attempt login with given details
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