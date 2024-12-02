import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:md_final/workout_page/firestore_manager.dart';

class ClockWidget extends StatelessWidget {
  const ClockWidget({super.key, required this.time});

  final DateTime time;

  @override
  Widget build(BuildContext context) {

    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {

        //fetch when the user started there workout from Firebase
        DateTime start = time;

        //calculate the difference and format it
        Duration difference = DateTime.now().difference(start);

        String output = "${difference.inHours}h ${difference.inMinutes.remainder(60)}m ${(difference.inSeconds.remainder(60))}s";

        return Text(output);
        // return Text(DateFormat('hh:mm:ss').format(DateTime.tryParse("2024-11-28 13:17:24.654294")!.difference(DateTime.now()).inHours));
      },
    );
  }
}