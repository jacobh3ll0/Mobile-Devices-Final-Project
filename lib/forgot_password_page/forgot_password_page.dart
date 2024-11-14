import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatelessWidget //Handles password resets (Using FireBase Definitions)
{
  final TextEditingController _emailController = TextEditingController();

  Future<void> _resetPassword(BuildContext context) async //Function that defines password resets
  {
    try
    {
      //Try to send password reset to email from text field.
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());

      //Show that the email was successfully sent via the snackbar on the login page
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Password reset email sent if the account exists. Check your inbox!"),
          backgroundColor: Colors.green, //Set success color to green
        ),
      );
      Navigator.pop(context); //Go back to login page
    }
    catch (e) //If the email failed to send (This is due to something other than account not existing)
    {
      //Display snack bar error saying it was a failure with error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send reset email: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) //Defines the forgot password screen layout
  {
    return Scaffold(
      appBar: AppBar(title: Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.only(top: 32.0), //Padding to top for aesthetics
        child: Align(
          alignment: Alignment.topCenter, //Set alignment
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 400), //Set a max height
              child: Column(
                children: [

                  //Explanation text
                  Text(
                    'Enter account email. If the account exists, a password reset email will be sent!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),


                  SizedBox(height: 25), //For ascetics

                  //Email field definition
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),

                  SizedBox(height: 25), //For Ascetics

                  //Define the button
                  ElevatedButton(
                    onPressed: () => _resetPassword(context), //Trigger resetPassword function with context for this page (For error)
                    child: Text('Reset Password'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}