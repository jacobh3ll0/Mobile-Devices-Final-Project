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


  // const HomePage({super.key});
  @override
  Widget build(BuildContext context)
  {
    User? user = FirebaseAuth.instance.currentUser; //Gets the current user information from the FireBase (Could be null in case of error)
    String UserEmail = user != null ? '${user.email}' : 'User not found'; //Set either user Email, or null (if error)

    return Scaffold(
      appBar: AppBar(
        leading: buildIconButtonProfile(),
          title: buildContainerTimeUser(),
          actions: [buildIconButtonTheme()],
          automaticallyImplyLeading: false),
      body:
          buildStackHomePage()
    );
  }
}

Widget buildStackHomePage()
{
  return Stack(
    children: [
      buildPositionBackground(),
      buildAlignHomePage()
    ],
  );
}

Widget buildPositionBackground()
{
  return Positioned.fill(
      child: Image.asset('lib/HomePage/test.gif',
          fit: BoxFit.cover));
}


Widget buildAlignHomePage()
{
  return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.only(top: 50.0),
        child: buildColumnHomePage(),
      )
  );
}

Widget buildColumnHomePage()
{
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      buildRowTimeRank(),
      buildSizedBox(),
      buildContainerQuote(),
      buildSizedBox(),
    ],
  );
}


Widget buildContainerTimeUser()
{
  return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: buildTextTime()
  );
}

Widget buildTextTime()
{
  return Text(
      getTime(),
      style: timeStyle()
  );
}


String calcTOD(int time)
{
  if (time >= 500 && time < 1159)
  {
    return "Good Morning! $time";
  }
  else if (time >= 1200 && time < 1559)
  {
    return "Good Afternoon! $time";
  }
  else if (time >= 1600 && time < 1959)
  {
    return "Good Evening! $time";
  }
  else
  {
    return "Good Night! $time";
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


Widget buildContainerQuote()
{
  return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: buildTextQuote()
  );
}

Widget buildTextQuote()
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
          style: timeStyle(),
        );
      }
      else
      {
        return const Text('No data available');
      }
    },
  );
}


Widget buildSizedBox()
{
  return SizedBox(
      height: 16.0);
}








TextStyle timeStyle()
{
  return const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.black, // Text color

  );
}

TextStyle quoteStyle() {
  return const TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: Colors.black,
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


Widget buildIconButtonProfile()
{
  return IconButton(
    icon: Image.asset('lib/HomePage/profile.png',
    width: 32.0, // Image size
    height: 32.0,
  ),
    onPressed: () {
      print("Image Button Pressed");
    });
}

Widget buildIconButtonTheme()
{
  return IconButton(
      icon: Icon(Icons.brush),
      onPressed: () {
        print("Image Button Pressed");
      },
  iconSize: 40.0, // Customize the icon size
  color: Colors.blue); // Customize the icon color);
}

Widget buildRowTimeRank()
{
  return Row(
    children: [
      buildContainerTime(),
      buildSizedBox(),
      buildContainerRank()
    ],
  );
}

Widget buildContainerTime()
{
  return Container();
}

Widget buildContainerRank()
{
  return Container();
}
