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
          backgroundColor: Colors.grey,
          leading: Padding(
          padding: const EdgeInsets.fromLTRB(8,0,0,8),
          child: buildContainerIconOutline(),
        ),
          centerTitle: true,
          title: Padding(
            padding: const EdgeInsets.fromLTRB(0,0,0,8),
            child: buildColumnGreeting(),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0,0,8,8),
              child: buildContainerThemeOutline(),
            )],
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
      child: Container(
      color: Colors.white54,
  ));
}


Widget buildAlignHomePage()
{
  return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.all(14),
        child: buildColumnHomePage(),
      )
  );
}

Widget buildColumnHomePage()
{
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      buildContainerMainModule(),
      buildSizedBoxVertical(),
      buildContainerSecondModule()
    ],
  );
}


Widget buildContainerMainModule()
{
  return Container(
    width: double.infinity,
    height: 200,
    padding: EdgeInsets.all(8.0),
    decoration: BoxDecoration(
      color: Colors.purpleAccent,
      borderRadius: BorderRadius.circular(12.0),
    ),
    child: buildStackMainModule(),
  );
}

Widget buildStackMainModule()
{
  return Stack(
    children: [
      buildPositionedMainModuleRight(),
      buildPositionedMainModuleLeft(),
    ],
  );
}


Widget buildPositionedMainModuleRight()
{
  return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      child:buildConstrainedBoxRank()

  );
}


Widget buildConstrainedBoxRank()
{
  return ConstrainedBox(
    constraints: BoxConstraints(
      maxWidth: 250,
    ),
    child: buildIconButtonRank(),
  );
}


Widget buildIconButtonRank()
{
  return IconButton(
    // icon: Icon(Icons.add),
    icon: Image.asset('Assets/Images/Ranks/Diamond_3_Rank.png'),
    onPressed: (){
      print("object");
    },
  );
}



Widget buildPositionedMainModuleLeft()
{
  return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      child: buildColumnMainModule()
  );
}



Widget buildColumnMainModule()
{
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      buildTextRank(),
      buildSizedBoxVertical(),
      buildConstrainedBoxRankQuote()
    ],
  );
}

Widget buildTextRank()
{
  return Text('DIAMOND', style: rankStyle());
}

Widget buildConstrainedBoxRankQuote()
{
  return ConstrainedBox(
      constraints: BoxConstraints(
      maxWidth: 250,
      ),
    child: buildTextQuote(),
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
          style: quoteStyle(),
          softWrap: true,
            overflow: TextOverflow.visible,
        );
      }
      else
      {
        return const Text('No data available');
      }
    },
  );
}

Widget buildContainerSecondModule()
{
  return Container(
    height: 100.0, // Set a fixed height for the blue container
    child: buildRowSecondModule(),
  );
}

Widget buildRowSecondModule()
{
  return Row(
    children: [
      buildExpandedCalender(),
      SizedBox(width: 8,),
      buildExpandedStreak()
    ],
  );
}

Widget buildExpandedCalender()
{
  return Expanded(
    flex: 3,
      child: buildContainerCalender());
}

Widget buildContainerCalender()
{
  return Container(
      height: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text('Calender')
  );
}

Widget buildExpandedStreak()
{
  return Expanded(
      flex: 1,
      child: buildContainerStreak());
}

Widget buildContainerStreak()
{
  return Container(
      padding: EdgeInsets.all(16.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.orangeAccent,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: IconButton(
          onPressed: (){
            print("object");
          },
          icon: Icon(Icons.local_fire_department))
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
    return "Good Morning,";
  }
  else if (time >= 1200 && time < 1559)
  {
    return "Good Afternoon,";
  }
  else if (time >= 1600 && time < 1959)
  {
    return "Good Evening,";
  }
  else
  {
    return "Good Night,";
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




Future<Map<String, dynamic>> getQuote() async
{
  final url = Uri.parse('https://zenquotes.io/api/today/');
  final response = await http.get(url);
  String quoteData = response.body.trim();
  List<dynamic> parsedQuote = jsonDecode(quoteData);
  Map<String, dynamic> quoteObject = parsedQuote[0];
  return quoteObject;

}



Widget buildContainerIconOutline()
{
  return Container(
    decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 2.0,
        ),
      borderRadius: BorderRadius.circular(100.0),
  ),
    child: buildIconButtonProfile(),
  );
}

Widget buildIconButtonProfile()
{
  return IconButton(
    icon: Image.asset('Assets/Images/profile.PNG'),
    iconSize: 32.0,
    onPressed: (){
      print("object");
    },
  );


}
Widget buildContainerThemeOutline()
{
  return Container(
    decoration: BoxDecoration(
      border: Border.all(
        color: Colors.black,
        width: 2.0,

      ),
      borderRadius: BorderRadius.circular(100.0),
    ),
    child: buildIconButtonTheme(),
  );
}

Widget buildIconButtonTheme()
{
  return IconButton(
      icon: Icon(Icons.settings),
      onPressed: () {
        print("Image Button Pressed");
      },
  iconSize: 30.0, // Customize the icon size
  color: Colors.black); // Customize the icon color);
}




Widget buildColumnGreeting()
{
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      buildTextTime(),
      buildTextUsername()
    ],
  );
}

Widget buildTextUsername()
{
  return Text('USER', style: usernameStyle());
}

Widget buildSizedBoxVertical()
{
  return SizedBox(height: 16.0);
}


Widget buildSizedBoxHorizontal()
{
  return SizedBox(width: 8);
}

TextStyle timeStyle()
{
  return const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black, // Text color

  );
}

TextStyle usernameStyle()
{
  return const TextStyle(
    fontSize: 16,
    color: Colors.black,
  );
}

TextStyle rankStyle()
{
  return const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.black
  );
}

TextStyle quoteStyle()
{
  return const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    shadows: [
      Shadow(
        offset: Offset(1.0, 1.0),
        blurRadius: 3.0,
        color: Colors.black
      )
    ]
  );
}







