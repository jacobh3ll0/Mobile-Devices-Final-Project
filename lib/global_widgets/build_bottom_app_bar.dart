import 'dart:developer';
import 'package:flutter/material.dart';

const List<IconData> constIconFilledList = [
  Icons.home,
  Icons.dining,
  Icons.local_fire_department,
  Icons.people,
  Icons.person,
];

const List<IconData> constIconOutlinedList = [
  Icons.home_outlined,
  Icons.dining_outlined,
  Icons.local_fire_department_outlined,
  Icons.people_outline,
  Icons.person_outline,
];

class BuildBottomNavigationBar extends StatefulWidget {
  final ValueChanged<int> onTap;
  final Function getIndex;

  const BuildBottomNavigationBar({super.key, required this.onTap, required this.getIndex});

  @override
  State<BuildBottomNavigationBar> createState() => _BuildBottomNavigationBarState();
}

class _BuildBottomNavigationBarState extends State<BuildBottomNavigationBar> {

  // map containing the icons
  List<IconData> iconList = [
    Icons.home_outlined,
    Icons.dining_outlined,
    Icons.local_fire_department_outlined,
    Icons.people_outline,
    Icons.person_outline,
  ];

  @override
  void initState() {
    iconList[0] = constIconFilledList[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return BottomNavigationBar(
      currentIndex: widget.getIndex(),
      onTap: (index) {
        _onIconPress(index);
      },
      selectedItemColor: Colors.blue,
      showSelectedLabels: true,
      unselectedItemColor: Colors.black,
      items: [
      BottomNavigationBarItem(icon: Icon(iconList[0]), label: "Home"),
      BottomNavigationBarItem(icon: Icon(iconList[1]), label: "Nutrition"),
      BottomNavigationBarItem(icon: Icon(iconList[2]), label: "Workout"),
      BottomNavigationBarItem(icon: Icon(iconList[3]), label: "Social"),
      BottomNavigationBarItem(icon: Icon(iconList[4]), label: "Profile"),
      ]
    );

  }

  void _onIconPress(int index) {
    widget.onTap(index);
    setState(() {
      for (int i = 0; i < iconList.length; i++) {
        iconList[i] = constIconOutlinedList[i]; //reset outlined icons
      }
      iconList[index] = constIconFilledList[index];
    });
  }



}


