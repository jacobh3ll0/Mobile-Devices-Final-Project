import 'package:flutter/material.dart';
import 'package:md_final/global_widgets/build_bottom_app_bar.dart';

class ProfilePage extends StatelessWidget {
  final VoidCallback logoutCallback;

  ProfilePage({required this.logoutCallback});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile Page"), automaticallyImplyLeading: false),
      body: Center(
        child: ElevatedButton(
        onPressed: logoutCallback, // Call the logout function
        child: Text('Logout'),
      ),
      ),
    );
  }
}