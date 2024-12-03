import 'package:flutter/material.dart';

class EqualSizedBoxesWithListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: 100, // Define the height of the red container
          width: double.infinity, // Make the container take the full width
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal, // Horizontal scrolling
            itemCount: 7, // 7 items for 7 days
            itemBuilder: (context, index) {
              return Container(
                width: (MediaQuery.of(context).size.width / 7) - 8, // Divide screen width into 7
                margin: const EdgeInsets.all(4.0), // Add spacing between purple squares
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.circle, color: Colors.black),
                    const SizedBox(height: 4.0), // Space between icon and text
                    Text(
                      getDayName(index),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2.0), // Space between day and number
                    Text(
                      getDayNumber(index).toString(),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Helper function to get day names
  String getDayName(int index) {
    List<String> days = ["Mon", "Tues", "Wed", "Thurs", "Fri", "Sat", "Sun"];
    return days[index];
  }

  // Helper function to get day numbers (mock values for this example)
  int getDayNumber(int index) {
    return [6, 5, 4, 3, 2, 1, 30][index];
  }
}

void main() {
  runApp(MaterialApp(
    home: EqualSizedBoxesWithListView(),
  ));
}
