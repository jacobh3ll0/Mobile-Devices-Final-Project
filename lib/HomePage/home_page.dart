import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:md_final/global_widgets/build_bottom_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:md_final/workout_page/firestore_manager.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:gif/gif.dart';
// import 'Assets/Main_Themes.dart';
// import 'Assets/Rank_Themes.dart';

class HomePage extends StatefulWidget
{
  const HomePage({super.key, required this.navigateToHomePageCallback});

  final Function navigateToHomePageCallback;

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
{
  Map<String, dynamic>? userData; //Map to store the fetched user data from DB
  String currentUser = "";
  FirestoreManager manager = FirestoreManager();
  late List<String> daysWorkedOut;

  @override
  void initState()
  {
    fetchUserData(); //Gets the users name, really inefficient, however funcitonal for now
    fetchCalendarData();
    super.initState();
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

  Future<void> fetchCalendarData() async {
    List<String> keys = await manager.getKeysForGroupedByDay();
    for(var item in keys) {
      log("date: $item");
    }
    daysWorkedOut = keys;
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
            child: buildContainerIconOutline(buildIconButtonProfile),
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
          buildStackHomePage(daysWorkedOut)
    );
  }

  Widget buildIconButtonProfile()
  {
    return GestureDetector(
      onTap: () {
        widget.navigateToHomePageCallback();
      },
      child: CircleAvatar(
        radius: 50,
        backgroundImage: userData != null &&
            userData?['profileImageURL'] != null &&
            userData!['profileImageURL'].toString().isNotEmpty
            ? NetworkImage(userData?['profileImageURL'])
            : null,
        child: userData == null ||
            userData?['profileImageURL'] == null ||
            userData!['profileImageURL'].toString().isEmpty
            ? const Icon(
          Icons.person,
          size: 50,
          color: Colors.grey, // Change background color of default profile picture for aesthetics
        )
            : null,
      ),

    );
  }

}

Widget buildStackHomePage(List<String> daysWorkedOut)
{
  return Stack(
    children: [
      buildPositionBackground(),
      buildAlignHomePage(daysWorkedOut)
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


Widget buildAlignHomePage(List<String> daysWorkedOut)
{
  return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.all(14),
        child: buildColumnHomePage(daysWorkedOut),
      )
  );
}

Widget buildColumnHomePage(List<String> daysWorkedOut)
{
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      buildContainerMainModule(),
      buildSizedBoxVertical(),
      buildContainerSecondModule(daysWorkedOut)
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

Widget buildContainerSecondModule(List<String> daysWorkedOut)
{
  return Container(
    height: 100.0, // Set a fixed height for the blue container
    child: buildRowSecondModule(daysWorkedOut),
  );
}

Widget buildRowSecondModule(List<String> daysWorkedOut)
{
  return Row(
    children: [
      buildExpandedCalender(),
      SizedBox(width: 8,),
      buildExpandedStreak(daysWorkedOut)
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
      child: const Text('Calender')
  );
}


Widget buildContainerStreak(List<String> daysWorkedOut)
{
  int streak = 0;
  for(var date in daysWorkedOut) {
    streak++;
  }

  return Container(
      padding: const EdgeInsets.all(2.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.orangeAccent,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Stack(
          alignment: Alignment.center,
          children: [
            const FittedBox(
              child: Icon(Icons.local_fire_department, size: 5000,),
            ),
            Text("$streak", style: streakStyle(),),
          ]
      )
  );
}

Widget buildExpandedStreak(List<String> daysWorkedOut)
{
  return Expanded(
    flex: 1,
    child: buildContainerStreak(daysWorkedOut));
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

Widget buildContainerIconOutline(Function buildIconButtonProfile)
{
  return Container(
    decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 2.0,
        ),
      borderRadius: BorderRadius.circular(100.0),
  ), child: Center(
      child: buildIconButtonProfile(),
    ),
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
    child: buildPopupMenuTheme(),
  );
}


Widget buildPopupMenuTheme() {
  return PopupMenuButton<int>(
    icon: Icon(Icons.brush),
    onSelected: (value) {
      if (value == 1) {
        print("Option 1 Selected");
      } else if (value == 2) {
        print("Option 2 Selected");
      }
    },
    itemBuilder: (context) =>
    [
      PopupMenuItem(
        value: 1,
        child: Text("Light"),
      ),
      PopupMenuItem(
        value: 2,
        child: Text("Dark"),
      )
    ],
  );
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

TextStyle streakStyle()
{
  return const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      shadows: [
        Shadow(
            offset: Offset(2.0, 2.0),
            blurRadius: 3.0,
            color: Colors.black
        )
      ]
  );
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
      child: buildListViewCalender()
  );
}

Widget buildListViewCalender()
{
  List<String> daysOfWeek = [
    "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"
  ];
  return ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: 7,
    itemBuilder: (context, index)
    {
      return buildContainerCalenderDay(daysOfWeek, index);
      },
    );
}


Widget buildContainerCalenderDay(List<String> daysOfWeek, int index)
{
  return Padding(
    padding: const EdgeInsets.all(5.0),
    child: Container(
      alignment: Alignment.center,
      color: Colors.purpleAccent,
      child: buildWrapCalender(daysOfWeek, index),
    ),
  );
}

Widget buildWrapCalender(List<String> daysOfWeek, int index)
{
  return Wrap(
    crossAxisAlignment: WrapCrossAlignment.center,
    direction: Axis.vertical,
    children: [
      buildIconCalender(),
      buildSizedBoxVertical(),
      Text(daysOfWeek[index], style: dayofweekStyle()),
      Text(DateTime.now().subtract(Duration(days: index - 4)).day.toString())
    ],
  );
}

Widget buildIconCalender()
{
  return Icon(Icons.fiber_manual_record);
}

// Bool didWorkout(int index,)
// {
//   String todayDate = DateTime.now().subtract(Duration(days: index - 4)).day.toString();
//   return
// }

TextStyle dayofweekStyle()
{
  return const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Colors.black,

  );
}













