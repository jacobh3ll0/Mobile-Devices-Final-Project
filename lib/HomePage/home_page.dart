import 'package:flutter/material.dart';
import 'package:md_final/global_widgets/build_bottom_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context)
  {
    User? user = FirebaseAuth.instance.currentUser; //Gets the current user information from the FireBase (Could be null in case of error)
    String UserEmail = user != null ? '${user.email}' : 'User not found :('; //Set either user Email, or null (if error)

    return Scaffold(
      appBar: AppBar(title: Text("Home Page"), automaticallyImplyLeading: false),
      body: Center(
        child: Text('Welcome back $UserEmail!'), //Simply here for demonstration that this works!
      ),
    );
  }
}