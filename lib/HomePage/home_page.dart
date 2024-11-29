import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:md_final/global_widgets/build_bottom_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:gif/gif.dart';

TextStyle test()
{
  return const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.yellow, // Text color
      shadows: [
        Shadow(
          blurRadius: 10.0,
          color: Colors.deepOrange,
          offset: Offset(2.0, 2.0),
        ),
      ],
  );
}
TextStyle quoteStyle() {
  return const TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: Colors.orangeAccent,
    shadows: [
      Shadow(
        blurRadius: 10.0,
        color: Colors.black,
        offset: Offset(2.0, 2.0),
      ),
    ],
  );
}

TextStyle timeStyle() {
  return const TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: Colors.red,
    shadows: [
      Shadow(
        blurRadius: 10.0,
        color: Colors.black,
        offset: Offset(2.0, 2.0),
      ),
    ],
  );
}





Future<Map<String, dynamic>> getQuote() async
{
  final url = Uri.parse('https://zenquotes.io/api/today/');
  final response = await http.get(url);
  String quoteData = response.body.trim();
  List<dynamic> parsedQuote = jsonDecode(quoteData);
  Map<String, dynamic> quoteObject = parsedQuote[0];
  return quoteObject;

}

class HomePage extends StatefulWidget
{
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}
class HomePageState extends State<HomePage>
{
  Map<String, dynamic>? userData; //Map to store the fetched user data from DB
  String currentUser = "";

  @override
  void initState()
  {
    super.initState();
    fetchUserData(); //Gets the users name, really inefficient, however funcitonal for now
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
              currentUser = userData?['displayName'] ?? "Unknown User";
            });
        }
      }
    }
    catch (e) //If it fails to grab the users data, output debug.
        {
      print("FAILED TO GRAB THE USERS DATA: $e");
    }
  }


  String calcTOD(int time)
  {
    if (time >= 500 && time < 1159)
    {
      return "Good Morning $currentUser! $time";
    }
    else if (time >= 1200 && time < 1559)
    {
      return "Good Afternoon $currentUser! $time";
    }
    else if (time >= 1600 && time < 1959)
    {
      return "Good Evening $currentUser! $time";
    }
    else
    {
      return "Good Night $currentUser! $time";
    }

  }

  String getTime()
  {
    final dt = DateTime.now();
    final dt24 = DateFormat('HH:mm').format(dt);
    final hour = dt.hour.toString().padLeft(2,'0');
    final min = dt.minute.toString().padLeft(2,'0');
    final inttime = int.parse('$hour$min');
    return calcTOD(inttime);
  }

  // const HomePage({super.key});
  @override
  Widget build(BuildContext context)
  {
    User? user = FirebaseAuth.instance.currentUser; //Gets the current user information from the FireBase (Could be null in case of error)
    String UserEmail = user != null ? '${user.email}' : 'User not found'; //Set either user Email, or null (if error)

    return Scaffold(
        appBar: AppBar(title: const Text("Home Page"), automaticallyImplyLeading: false),
        body:
            Stack(
              children: [
                Positioned.fill(
                  child: Image.asset('lib/HomePage/test.gif',
                  fit: BoxFit.cover)),
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
              Text(getTime(), style: quoteStyle()),
                // Text('', style: test(),),
                buildQuote()
              ],
            ),]
            ),


    );
  }


 Widget buildQuote()
  {
    return FutureBuilder<Map<String, dynamic>>
      (
      future: getQuote(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          final data = snapshot.data!;
          return Text(
            '"${data['q']}" — ${data['a']}',
            textAlign: TextAlign.center,
            style: test(),
          );
        }
        else
        {
          return const Text('No data available');
        }
      },
    );
  }
}