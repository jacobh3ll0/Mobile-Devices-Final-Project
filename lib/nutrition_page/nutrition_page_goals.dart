import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Definition of all available goals with their measurement units.
const Map<String, String> allAvailableGoals = {
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

// Stateful widget to manage and display user goals.
class NutritionPageGoals extends StatefulWidget {
  @override
  _NutritionPageGoalsState createState() => _NutritionPageGoalsState();
}

class _NutritionPageGoalsState extends State<NutritionPageGoals> {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // State to manage goals and available goals.
  List<Map<String, String>> goals = [];
  Map<String, String> availableGoals = {...allAvailableGoals};

  final TextEditingController goalController = TextEditingController();

  // Initial setup for fetching goals and initializing notifications.
  @override
  void initState() {
    super.initState();
    _fetchGoals();
    _initializeNotifications();
  }

  // Setup for local notifications.
  void _initializeNotifications() async {
    const AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: androidInitializationSettings);
    await _notificationsPlugin.initialize(initializationSettings);
  }

  // Send a local notification.
  Future<void> _sendNotification(String title, String body) async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'goals_channel',
      'Goals Notifications',
      channelDescription: 'Notifications for goals creation and updates',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
    await _notificationsPlugin.show(0, title, body, notificationDetails);
  }

  // Fetch goals from Firestore.
  void _fetchGoals() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        final snapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('goals')
            .get();
        setState(() {
          goals = snapshot.docs.map((doc) => {
            'type': doc.data()['type'] as String,
            'value': doc.data()['value'] as String,
          }).toList();

          // Remove already set goals from available options.
          for (var goal in goals) {
            availableGoals.remove(goal['type']);
          }
        });
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load goals. Please try again.'))
        );
      }
    }
  }

  // Add a new goal to Firestore.
  void _addGoal(String goalType, String value) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final goal = {'type': goalType, 'value': '$value${allAvailableGoals[goalType]!}'};
      _firestore.collection('users').doc(userId).collection('goals').add(goal).then((_) {
        setState(() {
          goals.add(goal);
          availableGoals.remove(goalType);
        });
        _sendNotification(
            "New $goalType Goal",
            "You have set a new $goalType goal: $value${allAvailableGoals[goalType]}."
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to add goal. Please try again.'))
        );
      });
    }
  }

  // Update an existing goal in Firestore.
  void _updateGoal(int index, String value) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final goalType = goals[index]['type']!;
    final unit = allAvailableGoals[goalType]!;

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('goals')
          .where('type', isEqualTo: goalType)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('goals')
            .doc(docId)
            .update({'value': "$value$unit"});

        setState(() {
          goals[index]['value'] = "$value$unit";
        });

        _sendNotification(
            "${goals[index]['type']} Goal Changed",
            "Your ${goals[index]['type']} goal is now $value$unit."
        );
      }
    } catch (error) {
      print("Error updating goal: $error");
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update goal. Please try again.'))
      );
    }
  }

  // Delete a goal from Firestore.
  void _deleteGoal(int index) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final goal = goals[index];
    try {
      final goalType = goal['type']!;

      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('goals')
          .where('type', isEqualTo: goalType)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;

        await _firestore
            .collection('users')
            .doc(userId)
            .collection('goals')
            .doc(docId)
            .delete();

        setState(() {
          goals.removeAt(index);
          availableGoals[goalType] = allAvailableGoals[goalType]!;
        });

        _sendNotification(
            "Removed $goalType Goal",
            "You have removed the $goalType goal."
        );
      }
    } catch (error) {
      print("Error deleting goal: $error");
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete goal.'))
      );
    }
  }

  // Display a dialog to add new goals.
  void _openAddGoalDialog() {
    if (availableGoals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All goals have been set.'))
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add New Goal"),
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

  // Display a dialog to set or update goals.
  void _openSetGoalDialog(String goalType, [int? index]) {
    goalController.text = index != null
        ? goals[index]['value']?.replaceAll(RegExp(r'\D+'), '') ?? ''
        : '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(index == null ? "Set Goal for $goalType" : "Change Goal for $goalType"),
          content: TextField(
            controller: goalController,
            decoration: InputDecoration(
              labelText: "Enter $goalType goal",
              border: const OutlineInputBorder(),
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
                  goalController.clear();
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: const Text('Please enter a valid number', style: const TextStyle(color: Colors.black),), backgroundColor: Colors.grey[200],)
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28.0),
                ),
              ),
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [],
            ),
          ),
          Expanded(
            child: goals.isEmpty
                ? const Center(child: Text("No goals set"))
                : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.separated(
                itemCount: goals.length,
                itemBuilder: (context, index) {
                  final goalType = goals[index]['type']!;
                  final goalValue = goals[index]['value']!;
                  return Card(
                    elevation: 4.0,
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      title: Text(
                        goalType,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(goalValue),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () => _openSetGoalDialog(goalType, index),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28.0),
                              ),
                            ),
                            child: const Text("Change"),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _deleteGoal(index),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28.0),
                              ),
                            ),
                            child: const Text("Delete"),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(height: 4.0),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddGoalDialog,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28.0),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
