import 'dart:developer';
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

TextStyle quoteStyle() {
  return TextStyle(
    fontSize: 28,
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

TextStyle timeStyle() {
  return TextStyle(
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

String calcTOD(int time)
{
  if (time >= 500 && time < 1159)
    {
      return "Good Morning User! $time";
    }
  else if (time >= 1200 && time < 1559)
    {
      return "Good Afternoon User! $time";
    }
  else if (time >= 1600 && time < 1959)
    {
      return "Good Evening User! $time";
    }
  else
    {
      return "Good Night User! $time";
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

class HomePage extends StatefulWidget
{
  @override
  HomePageState createState() => HomePageState();
}
class HomePageState extends State<HomePage>
{

  @override
  void initState()
  {
    super.initState();

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
                Text(''),
              Text(getTime(), style: timeStyle()),
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
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          final data = snapshot.data!;
          return Text(
            '"${data['q']}" — ${data['a']}',
            textAlign: TextAlign.center,
            style: quoteStyle(),
          );
        }
        else
        {
          return Text('No data available');
        }
      },
    );
  }
}
