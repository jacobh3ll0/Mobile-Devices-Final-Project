import 'dart:developer';
import 'package:flutter/material.dart';

BottomAppBar buildBottomAppBar(BuildContext context) {
  log(ModalRoute.of(context)!.debugLabel, name: "bottom app bar");

  return BottomAppBar(
    color: Colors.blue,
    child: Row(
      children: <Widget> [
        IconButton(
          tooltip: 'Home',
          icon: const Icon(Icons.home_outlined),
          onPressed: () {
            // if (Navigator.canPop(context)) Navigator.pop(context); //pop current page
            // Navigator.pushNamed(context, '/home');
            Navigator.pushNamedAndRemoveUntil(context, '/home', (Route<dynamic> route) => false);
          },
        ),
        IconButton(
          tooltip: 'Nutrition',
          icon: const Icon(Icons.dining_outlined),
          onPressed: () {
            // if (Navigator.canPop(context)) Navigator.pop(context); //pop current page
            // Navigator.pushNamed(context, '/nutrition');
            Navigator.pushNamedAndRemoveUntil(context, '/nutrition', (Route<dynamic> route) => false);
          },
        ),
        IconButton(
          tooltip: 'Start Workout',
          icon: const Icon(Icons.local_fire_department_outlined),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/workout', (Route<dynamic> route) => false);
          },
        ),
        IconButton(
          tooltip: 'Social',
          icon: const Icon(Icons.people_outline),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/social', (Route<dynamic> route) => false);
          },
        ),
        IconButton(
          tooltip: 'Profile',
          icon: const Icon(Icons.person_outline),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/profile', (Route<dynamic> route) => false);
          },
        ),
      ],
    ),
  );
}