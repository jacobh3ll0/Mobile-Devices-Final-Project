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

String calcTOD(int time)
{
  if (time >= 500 && time < 1159)
    {
      return "Good Morning User!";
    }
  else if (time >= 1200 && time < 1559)
    {
      return "Good Afternoon User!";
    }
  else if (time >= 1600 && time < 1959)
    {
      return "Good Evening User!";
    }
  else
    {
      return "Good Night User!";
    }

}

String getTime()
{
  final dt = DateTime.now();
  final dt24 = DateFormat('HH:mm').format(dt);
  final hour = dt.hour.toString().padLeft(2,'0');
  final min = dt.minute.toString().padLeft(2,'0');
  final inttime = int.parse('$hour$min');
  getQuote();
  return calcTOD(inttime);

}

void getQuote() async
{
  final url = Uri.parse('https://zenquotes.io/api/today/');
  final response = await http.get(url);
  String quoteData = response.body.trim();
  List<dynamic> parsedQuote = jsonDecode(quoteData);
  Map<String, dynamic> quoteObject = parsedQuote[0];
  log(quoteData);
  log(quoteObject['q']);
  log(quoteObject['a']);

}



class HomePage extends StatefulWidget
{
  @override
  HomePageState createState() => HomePageState();
}
class HomePageState extends State<HomePage>
{
  // const HomePage({super.key});
  @override
  Widget build(BuildContext context)
  {
    User? user = FirebaseAuth.instance.currentUser; //Gets the current user information from the FireBase (Could be null in case of error)
    String UserEmail = user != null ? '${user.email}' : 'User not found :('; //Set either user Email, or null (if error)

    return Scaffold(
        appBar: AppBar(title: Text("Home Page"), automaticallyImplyLeading: false),
        body:
        Container(
          decoration: BoxDecoration(
            // image: DecorationImage(
            //     image: AssetImage("testimage.PNG"),
            //     fit: BoxFit.cover),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(getTime()),
                  Text("INSERT TOWN/CITY"),

                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text('Hello'),
                ],
              )
            ],
          ),
        )
    );
  }
}
