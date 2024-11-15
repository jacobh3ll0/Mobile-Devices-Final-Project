import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NutritionPageGoals extends StatefulWidget {
  @override
  _NutritionPageGoalsState createState() => _NutritionPageGoalsState();
}

class _NutritionPageGoalsState extends State<NutritionPageGoals> {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  List<Map<String, String>> goals = [];
  Map<String, String> availableGoals = {
    'Calories': 'cal',
    'Protein': 'g',
    'Fat': 'g',
    'Carbs': 'g',
    'Fiber': 'g',
    'Saturated Fat': 'g',
    'Cholesterol': 'mg',
    'Sugar': 'g',
    'Sodium': 'mg',
  };

  final TextEditingController goalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchGoals();
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: androidInitializationSettings);
    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _sendNotification(String title, String body) async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'goals_channel',
      'Goals Notifications',
      channelDescription: 'Notifications for goals creation and updates',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
    await _notificationsPlugin.show(0, title, body, notificationDetails);
  }

  void _fetchGoals() {
    goals = [
      {'type': 'Calories', 'value': '2000 cal'},
      {'type': 'Protein', 'value': '150 g'},
      {'type': 'Fat', 'value': '70 g'},
    ];
    for (var goal in goals) {
      availableGoals.remove(goal['type']);
    }
    setState(() {});
  }

  void _addGoal(String goalType, String value) {
    setState(() {
      goals.add({'type': goalType, 'value': "$value${availableGoals[goalType]}"});
      availableGoals.remove(goalType);
    });
    _sendNotification(
      "New $goalType Goal",
      "You have set a new $goalType goal: $value${availableGoals[goalType]}.",
    );
  }

  void _updateGoal(int index, String value) {
    final String unit = availableGoals[goals[index]['type']] ?? '';
    setState(() {
      goals[index]['value'] = "$value$unit";
    });
    _sendNotification(
      "${goals[index]['type']} Goal Changed",
      "Your ${goals[index]['type']} goal is now $value$unit.",
    );
  }

  void _deleteGoal(int index) {
    final goal = goals[index];
    setState(() {
      availableGoals[goal['type']!] = goal['value']!.replaceAll(RegExp(r'\d+'), '');
      goals.removeAt(index);
    });
    _sendNotification(
      "Removed ${goal['type']} Goal",
      "You have removed the ${goal['type']} goal.",
    );
  }

  void _openAddGoalDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add New Goal"),
          content: SingleChildScrollView(
            child: Column(
              children: availableGoals.keys.map((goalType) {
                return ListTile(
                  title: Text(goalType),
                  onTap: () {
                    Navigator.pop(context);
                    _openSetGoalDialog(goalType);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _openSetGoalDialog(String goalType, [int? index]) {
    goalController.text = index != null
        ? goals[index]['value']?.replaceAll(RegExp(r'\D+'), '') ?? ''
        : '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Set Goal for $goalType"),
          content: TextField(
            controller: goalController,
            decoration: InputDecoration(
              labelText: "Enter $goalType goal",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                final enteredValue = goalController.text;
                if (enteredValue.isNotEmpty && int.tryParse(enteredValue) != null) {
                  if (index == null) {
                    _addGoal(goalType, enteredValue);
                  } else {
                    _updateGoal(index, enteredValue);
                  }
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a valid number')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28.0),
                ),
              ),
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: ListView.builder(
        itemCount: goals.length,
        itemBuilder: (context, index) {
          final goal = goals[index];
          return Card(
            elevation: 4.0,
            margin: const EdgeInsets.all(8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ListTile(
              title: Text(goal['type'] ?? ""),
              subtitle: Text(goal['value'] ?? ""),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () => _openSetGoalDialog(goal['type'] ?? "", index),
                    child: Text("Change"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28.0),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _deleteGoal(index),
                    child: Text("Delete"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddGoalDialog,
        backgroundColor: Colors.lightBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28.0),
        ),
        child: Icon(Icons.add),
      ),
    );
  }
}
