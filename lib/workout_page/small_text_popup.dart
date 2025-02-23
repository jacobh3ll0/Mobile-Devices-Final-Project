import 'package:flutter/material.dart';

// THIS SMALL POPUP WAS GENERATED BY CHATGPT


Future<Map<String, double?>?> showNumberDialog(BuildContext context) async {
  TextEditingController intController = TextEditingController();
  TextEditingController floatController = TextEditingController();

  // Show the dialog and return the entered numbers (or null if cancelled)
  return showDialog<Map<String, double?>>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Enter New Set Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Input field for the integer
            TextField(
              controller: intController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter The Reps (integer)',
              ),
            ),
            const SizedBox(height: 10),
            // Input field for the float
            TextField(
              controller: floatController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: 'Enter The Weight (float)',
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog without returning a value
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Try to parse the integer and float
              final intNumber = int.tryParse(intController.text);
              final doubleNumber = double.tryParse(floatController.text);

              if (intNumber != null && doubleNumber != null) {
                // Return the entered values as a Map
                Navigator.of(context).pop({
                  'intNumber': intNumber.toDouble(), // Return as double for consistency
                  'floatNumber': doubleNumber,
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter valid numbers!'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
