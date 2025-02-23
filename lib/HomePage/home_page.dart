import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:md_final/workout_page/firestore_manager.dart';

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
  late List<String> daysWorkedOut = [];

  @override
  void initState()
  {
    fetchUserData(); //Gets the users name, really inefficient, however functional for now
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
      log("FAILED TO GRAB THE USERS DATA: $e");
    }
  }

  bool didWorkout(currentDay)
  {
    if (daysWorkedOut.contains(currentDay))
      {
        return true;
      }
    else
      {
        return false;
      }
  }

  Future<void> fetchCalendarData() async {
    List<String> keys = await manager.getKeysForGroupedByDay();
    daysWorkedOut = keys;
  }

  // const HomePage({super.key});
  @override
  Widget build(BuildContext context)
  {
    // User? user = FirebaseAuth.instance.currentUser; //Gets the current user information from the FireBase (Could be null in case of error)
    // String UserEmail = user != null ? '${user.email}' : 'User not found'; //Set either user Email, or null (if error)

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
          // actions: [
            // Padding(
            //   padding: const EdgeInsets.fromLTRB(0,0,8,8),
            //   child: buildContainerThemeOutline(),
            // )],
          automaticallyImplyLeading: false),
      body:
          buildStackHomePage()
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
          size: 40,
          color: Colors.grey, // Change background color of default profile picture for aesthetics
        )
            : null,
      ),

    );
  }


Widget buildStackHomePage()
{
  return Stack(
    children: [
      buildAlignHomePage()
    ],
  );
}




Widget buildAlignHomePage()
{
  return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(14),
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
    padding: const EdgeInsets.all(8.0),
    decoration: BoxDecoration(
      color: Colors.red,
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
    constraints: const BoxConstraints(
      maxWidth: 250,
    ),
    child: buildIconButtonRank(),
  );
}


Widget buildIconButtonRank()
{
  return IconButton(
    // icon: Icon(Icons.add),
    icon: Image.asset('Assets/Images/Ranks/dumbbell.png'),
    // icon: Image.asset('Assets/Images/Ranks/Diamond_3_Rank.png'),
    onPressed: (){},
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
      // buildTextRank(),
      buildSizedBoxVertical(),
      buildConstrainedBoxRankQuote()
    ],
  );
}

// Widget buildTextRank()
// {
//   return Text('DIAMOND', style: rankStyle());
// }

Widget buildConstrainedBoxRankQuote()
{
  return ConstrainedBox(
      constraints: const BoxConstraints(
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
  return SizedBox(
    height: 100.0, // Set a fixed height for the blue container
    child: buildRowSecondModule(),
  );
}

Widget buildRowSecondModule()
{
  return Row(
    children: [
      buildExpandedCalendar(),
      const SizedBox(width: 8,),
      buildExpandedStreak()
    ],
  );
}

Widget buildExpandedCalendar()
{
  return Expanded(
    flex: 3,
      child: buildContainerCalendar());
}


  Widget buildContainerStreak()
  {

    int streak = 0;
    for(String date in daysWorkedOut) {
      // log("date: $date, s: $streak");
      DateTime time = DateTime.now();
      String stringToday = "${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')}";
      DateTime today = DateTime.parse(stringToday);

      DateTime currentDay = DateTime.parse(date);

      if(today.subtract(Duration(days: streak)) == currentDay) {
        streak++;
      } else {
        break;
      }

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


Widget buildExpandedStreak()
{
  return Expanded(
    flex: 1,
    child: buildContainerStreak());
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

// Widget buildContainerThemeOutline()
// {
//   return Container(
//     decoration: BoxDecoration(
//       border: Border.all(
//         color: Colors.black,
//         width: 2.0,
//       ),
//       borderRadius: BorderRadius.circular(100.0),
//     ),
//     child: buildPopupMenuTheme(),
//   );
// }
//
//
// Widget buildPopupMenuTheme() {
//   return PopupMenuButton<int>(
//     icon: const Icon(Icons.brush),
//     onSelected: (value) {
//       if (value == 1) {
//         print("Option 1 Selected");
//       } else if (value == 2) {
//         print("Option 2 Selected");
//       }
//     },
//     itemBuilder: (context) =>
//     [
//       const PopupMenuItem(
//         value: 1,
//         child: Text("Light"),
//       ),
//       const PopupMenuItem(
//         value: 2,
//         child: Text("Dark"),
//       )
//     ],
//   );
// }

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
  return Text(currentUser, style: usernameStyle());
}

Widget buildSizedBoxVertical()
{
  return const SizedBox(height: 16.0);
}


Widget buildSizedBoxHorizontal()
{
  return const SizedBox(width: 8);
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

Widget buildContainerCalendar()
{
  return Container(
      height: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: buildListViewCalendar()
  );
}

Widget buildListViewCalendar()
{
  List<String> daysOfWeek = [
    "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"
  ];
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: List.generate(
      daysOfWeek.length,
          (index) => buildContainerCalendarDay(daysOfWeek, index),
    ),
  );
}


Widget buildContainerCalendarDay(List<String> daysOfWeek, int index)
{
  return Padding(
    padding: const EdgeInsets.all(5.0),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.black,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(100.0),
      ),
      alignment: Alignment.center,
      child: buildWrapCalendar(daysOfWeek, index),
    ),
  );
}

Widget buildWrapCalendar(List<String> daysOfWeek, int index)
{
  return Wrap(
    crossAxisAlignment: WrapCrossAlignment.center,
    direction: Axis.vertical,
    children: [
      buildIconCalendar(DateTime.now().add(Duration(days: index - 5))),
      buildSizedBoxVertical(),
      Text(daysOfWeek[(DateTime.now().add(Duration(days: index - 5)).weekday - 1) % 7], style: dayofweekStyle()),
      Text(DateTime.now().add(Duration(days: index - 5)).day.toString(), style: dayofweekStyle()),
    ],
  );
}

Widget buildIconCalendar(DateTime dateTimeIndex)
{
  //prepare datetime object
  DateTime time = dateTimeIndex;
  String stringToday = "${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')}";
  DateTime today = DateTime.parse(stringToday);

  for(String currentDay in daysWorkedOut) {
    DateTime current = DateTime.parse(currentDay);

    if(today == current) {
      return const Icon(Icons.fiber_manual_record, color: Colors.black,);
    }
  }
  return const Icon(Icons.circle_outlined, color: Colors.black);
}

TextStyle dayofweekStyle()
{
  return const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: Colors.black,

  );
}

}











