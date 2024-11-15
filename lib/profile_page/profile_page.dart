import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:md_final/global_widgets/build_bottom_app_bar.dart';

class ProfilePage extends StatefulWidget
{
  final VoidCallback logoutCallback;
  ProfilePage({required this.logoutCallback});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
{
  Map<String, dynamic>? userData; //Map to store the fetched user data from DB

  @override
  void initState() //When the page loads, fetch the user data
  {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async //Function to handle retrieving the user data
  {
    try
    {
      User? user = FirebaseAuth.instance.currentUser; //Get the current user

      if (user != null) //Make sure they are not null
      {
        String uid = user.uid; //Store their id

        //fetch the user data from the database using their id
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (userDoc.exists) //If a user document exists
        {
          setState(()
          {
            userData = userDoc.data() as Map<String, dynamic>; //put the data into a map
          });
        }
      }
    }
    catch (e) //If it fails to grab the users data, output debug.
    {
      print("FAILED TO GRAB THE USERS DATA: $e");
    }
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile Page"),
        automaticallyImplyLeading: false, //Doesnt show back button
      ),

      //Body definition

      //If the userData does not exist, show that no user data is found as a text title
      body: userData == null ? Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(child: Text("No user data found.")),
      )
      //Otherwise, output all of the users information on the profile page
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [


            //Circle avatar (Profile Picture) definition
            Center(
              child: CircleAvatar(
                radius: 50,
                //Check for background picture as null value. and if so, just display the person icon in the circle avatar
                backgroundImage: userData!['profileImageURL'] != null &&
                    userData!['profileImageURL'].toString().isNotEmpty
                    ? NetworkImage(userData!['profileImageURL'])
                    : null,
                child: userData!['profileImageURL'] == null ||
                    userData!['profileImageURL'].toString().isEmpty
                    ? Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.grey, //Change background color of default profile picture for aesthetics
                )
                    : null,
              ),
            ),

            SizedBox(height: 20), //Spacing for aesthetics

            //DisplayName format definition
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Display Name:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "${userData!['displayName'] ?? 'N/A'}",
                style: TextStyle(fontSize: 16),
              ),
            ),

            SizedBox(height: 15),//Spacing for aesthetics

            //Description format definition
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Description:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "${userData!['description'] ?? 'N/A'}",
                style: TextStyle(fontSize: 16),
              ),
            ),

            SizedBox(height: 15), //Spacing for aesthetics

            //Gender format definition
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Gender:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "${userData!['gender'] ?? 'N/A'}",
                style: TextStyle(fontSize: 16),
              ),
            ),

            SizedBox(height: 15), //Spacing for aesthetics

            //Gym experience format definition
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Gym Experience:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "${userData!['gymExperience'] ?? 'N/A'}",
                style: TextStyle(fontSize: 16),
              ),
            ),

            SizedBox(height: 30), //Spacing for aesthetics

            //Logout button definition
            Center(
              child: ElevatedButton(
                onPressed: widget.logoutCallback, // Logout callback
                child: Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}