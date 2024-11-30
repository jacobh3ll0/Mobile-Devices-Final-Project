import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_creation_page.dart';

class SignUpPage extends StatelessWidget //Handles first level of user sign up (Email and Password) using FireBase. Will have another page for further details.
{
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();


  Future<bool> _signUp(BuildContext context) async //Function to handle a signup attempt
  {

    try //Try inputted information
    {

      //Create the user account, and get the usercredential
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _emailController.text.trim().toLowerCase(), password: _passwordController.text.trim().toLowerCase());

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileCreationPage(uid: userCredential.user!.uid), //Navigate to the profile creation with the usercredential
        ),
      );

      return true;

    }
    on FirebaseAuthException catch (e) //Firebase exception handling
    {
      String errorMessage;

      // Handle specific Firebase Authentication errors
      if (e.code == 'email-already-in-use') {
        errorMessage =
        'This email address is already in use. Please try logging in instead.';
      } else if (e.code == 'invalid-email') {
        errorMessage =
        'The email address is invalid. Please provide a valid email!';
      } else if (e.code == 'weak-password')
      {
        errorMessage =
        'The password is too weak. Please provide a stronger password.';
      } else
      {
        errorMessage = 'Account creation failed. Please try again later.';
      }

      // Show the error in a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    catch (e) //If signup fails, output error to snackbar (This should only happen in error, my input validation should catch any errors)
    {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Whoops, that should not have happened! Account Creation Failed: $e'), //Error message
          backgroundColor: Colors.red, //Set color red
        ),
      );
    }
    return false;
  }

  @override
  Widget build(BuildContext context) //Defines the signup page
  {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.only(top: 32.0), //Pad the top for aesthetics
        child: Align(
          alignment: Alignment.topCenter, //Set alignment
          child: Padding(
            padding: const EdgeInsets.all(20.0), //Pad for aesthetics
            child: Column(
              children: [
                //First email box definition
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey, //color of non-focus border
                        width: 1.0, //boarder thickness
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blue, //color when focused
                        width: 2.0, //thickness when focused
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 30), //For aesthetics

                //Confirm email definition
                TextField(
                  controller: _confirmEmailController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Email',
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blue,
                        width: 2.0,
                      ),
                    ),
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
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blue,
                        width: 2.0,
                      ),
                    ),
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
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blue,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 50), //For aesthetics

                //Button at the bottom to proceed to profile creation
                ElevatedButton(
                  onPressed: () async
                  {
                    //Validate the user input

                    //Make sure not empty
                    if (_emailController.text.isNotEmpty && _confirmEmailController.text.isNotEmpty && _passwordController.text.isNotEmpty && _confirmPasswordController.text.isNotEmpty)
                    {
                      //Make sure the emails are not different
                      if (_emailController.text.trim().toLowerCase() != _confirmEmailController.text.trim().toLowerCase())
                      {
                        ScaffoldMessenger.of(context).showSnackBar( //Output error
                          SnackBar(
                            content: Text('Your emails MUST match'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                      //Make sure the passwords are not different
                      else if (_passwordController.text != _confirmPasswordController.text)
                      {
                        ScaffoldMessenger.of(context).showSnackBar( //Output error
                          SnackBar(
                            content: Text('Your passwords MUST match!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                      else //If email and password are matches
                      {
                        //Verify the email is in proper format
                        if(!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(_emailController.text))
                          {
                            ScaffoldMessenger.of(context).showSnackBar( //Output error if not
                              // Output error
                              SnackBar(
                                content: Text('Not a valid email!'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        //Make sure passwords are not out of range
                        else if(_passwordController.text.length < 6 && _passwordController.text.length > 30)
                          {
                            ScaffoldMessenger.of(context).showSnackBar( //Output error message
                              // Output error
                              SnackBar(
                                content: Text('Password MUST be between 6 to 30 characters'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        else
                          {
                            //Wait for the signup to complete -> Requires profile completion and preferences filled out before being done
                            final bool signupSuccess = await _signUp(context);

                            if(signupSuccess)
                              {
                                Navigator.pop(context); //Return to login after full account is made
                              }

                          }
                      }
                    }
                    else //If the all fields are not filled
                    {
                      ScaffoldMessenger.of(context).showSnackBar(
                        // Output error
                        SnackBar(
                          content: Text('All fields are required!'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Text('Proceed to profile creation!'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}