import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpPage extends StatelessWidget //Handles first level of user sign up (Email and Password) using FireBase. Will have another page for further details.
{
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  Future<void> _signUp(BuildContext context) async //Function to handle a signup attempt
  {
    try //Try inputted information
    {

      //Create the user credential
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _emailController.text.trim(), password: _passwordController.text.trim());

      //When account is succesfully created, display this snack bar on login screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Account creation successful!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); //Return to login
    }
    catch (e) //If signup fails, output error to snackbar
    {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign-Up failed: $e'), //Errorr message
          backgroundColor: Colors.red, //Set color red
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) //Defines the signup page
  {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.only(top: 32.0), //Pad the top for athletics
        child: Align(
          alignment: Alignment.topCenter, //Set alignment
            child: Padding(
              padding: const EdgeInsets.all(16.0), //Pad for aesthetics
              child: Column(
                children: [

                  //First email box definition
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(height: 30), //For aesthetics

                  //Confirm email definition
                  TextField(
                    controller: _confirmEmailController,
                    decoration: InputDecoration(
                      labelText: 'Confirm Email',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(height: 30), //For aesthetics

                  //Password field definition
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(height: 30), //For aesthetics

                  //Confirm password field definition
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(height: 50), //For aesthetics

                  //Create account button
                  ElevatedButton(
                    onPressed: ()
                    {
                      if (_emailController.text.trim() != _confirmEmailController.text.trim()) //If both emails dont match
                      {
                        ScaffoldMessenger.of(context).showSnackBar( //Output error to snackbar
                          SnackBar(
                            content: Text('Your emails MUST match'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                      else if (_passwordController.text != _confirmPasswordController.text) //If both password fields dont match
                      {
                        ScaffoldMessenger.of(context).showSnackBar( //Output error
                          SnackBar(
                            content: Text('Your passwords MUST match!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                      else //Otherwise send to firebase for signup (Still must meet firebase requirements @ .com and > 6 characters)
                      {
                        _signUp(context);
                      }
                    },
                    child: Text('Create Account'),
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }
}