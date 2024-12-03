import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class NutritionPageDashboard extends StatefulWidget {
  const NutritionPageDashboard({super.key});

  @override
  _NutritionPageDashboardState createState() => _NutritionPageDashboardState();
}

class _NutritionPageDashboardState extends State<NutritionPageDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic> goals = {};
  Map<String, Map<String, num>> weeklyLogs = {}; // Holds logs per day per goal

  // Variable to track the selected date
  DateTime selectedDate = DateTime.now();

  // Mapping from goal types to their corresponding nutrient fields
  final Map<String, String> goalToNutrientMap = {
    'Calories': 'calories',
    'Protein': 'protein',
    'Fat': 'fat',
    'Carbs': 'carbs',
    'Fiber': 'fiber',
    'Saturated Fat': 'saturatedFat',
    'Cholesterol': 'cholesterol',
    'Sugar': 'sugar',
    'Sodium': 'sodium',
  };

  @override
  void initState() {
    super.initState();
  }

  // Helper method to get the start of the week (Sunday)
  DateTime _startOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday % 7));
  }

  // Helper method to get the end of the week (Saturday)
  DateTime _endOfWeek(DateTime date) {
    return _startOfWeek(date).add(const Duration(days: 6));
  }

  // Method to navigate days
  void _changeDay(int days) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: days));
    });
  }

  Stream<Map<String, dynamic>> _fetchDashboardData() async* {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    // Calculate the start and end dates of the week containing the selected date
    final startOfWeek = _startOfWeek(selectedDate);
    final endOfWeek = _endOfWeek(selectedDate);

    // Format dates as 'yyyy-MM-dd'
    final startDateStr = DateFormat('yyyy-MM-dd').format(startOfWeek);
    final endDateStr = DateFormat('yyyy-MM-dd').format(endOfWeek);


    // Goals Stream
    final goalsStream = _firestore
        .collection('users')
        .doc(userId)
        .collection('goals')
        .snapshots();

    // Meal Logs Stream within the selected week
    final mealLogsStream = _firestore
        .collection('users')
        .doc(userId)
        .collection('mealLogs')
        .where('date', isGreaterThanOrEqualTo: startDateStr)
        .where('date', isLessThanOrEqualTo: endDateStr)
        .snapshots();

    // Listen to goals changes
    await for (final goalsSnapshot in goalsStream) {
      final Map<String, dynamic> newGoals = {};
      for (var doc in goalsSnapshot.docs) {
        final data = doc.data();
        newGoals[data['type']] =
            int.tryParse(data['value']?.replaceAll(RegExp(r'\D+'), '') ?? '0') ?? 0;
      }

      // Listen to meal logs changes within the week
      await for (final mealLogsSnapshot in mealLogsStream) {
        final Map<String, Map<String, num>> newWeeklyLogs = {};

        // Initialize weeklyLogs for each goal type and each day
        for (var goalType in newGoals.keys) {
          String nutrientField = goalToNutrientMap[goalType] ?? '';
          if (nutrientField.isEmpty) continue; // Skip if no mapping exists

          newWeeklyLogs[goalType] = {};
          for (int i = 0; i < 7; i++) {
            DateTime day = startOfWeek.add(Duration(days: i));
            String dayStr = DateFormat('yyyy-MM-dd').format(day);
            newWeeklyLogs[goalType]![dayStr] = 0;
          }
        }

        for (var doc in mealLogsSnapshot.docs) {
          final data = doc.data();

          final dateStr = data['date'] ?? '';

          if (dateStr.isEmpty) continue;

          // Determine which goal types are present in this meal log
          for (var goalType in newGoals.keys) {
            String nutrientField = goalToNutrientMap[goalType] ?? '';
            if (nutrientField.isEmpty || !data.containsKey(nutrientField)) continue;

            final nutrientValue =
            (data[nutrientField] is num) ? data[nutrientField] as num : 0.0;

            if (newWeeklyLogs[goalType]!.containsKey(dateStr)) {
              newWeeklyLogs[goalType]![dateStr] =
                  (newWeeklyLogs[goalType]![dateStr] ?? 0) + nutrientValue;
              (
                  "Updated $goalType for $dateStr: ${newWeeklyLogs[goalType]![dateStr]}");
            }
          }
        }

        yield {'goals': newGoals, 'weeklyLogs': newWeeklyLogs};
      }
    }
  }

  Widget _buildGoalCard(String goalType) {
    final goalValue = goals[goalType] ?? 1; // Default to 1 to avoid division by zero

    // Get the start of the week
    final startOfWeek = _startOfWeek(selectedDate);

    // Generate list of dates for the week
    List<DateTime> weekDates = List.generate(7, (index) {
      return startOfWeek.add(Duration(days: index));
    });

    // Labels for days of the week
    final dayLabels = ['Su', 'M', 'Tu', 'W', 'Th', 'F', 'Sa'];

    // Today's date for comparison
    final today = DateTime.now();

    // Selected date string
    final selectedDayStr = DateFormat('yyyy-MM-dd').format(selectedDate);

    // Prepare week data based on the selected week
    final weekData = [
      for (int i = 0; i < 7; i++)
        weeklyLogs[goalType]?[DateFormat('yyyy-MM-dd').format(weekDates[i])] ?? 0
    ];

    // Determine which day is selected within the week
    int selectedDayIndex = weekDates.indexWhere(
            (date) => DateFormat('yyyy-MM-dd').format(date) == selectedDayStr);
    if (selectedDayIndex == -1) {
      // If selectedDate is not within the current week (shouldn't happen)
      selectedDayIndex = today.weekday % 7; // Default to today
    }

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(goalType,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 80,
                      width: 80,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 8,
                        valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.grey[300]!),
                        backgroundColor: Colors.transparent,
                      ),
                    ),

                    SizedBox(
                      height: 80,
                      width: 80,
                      child: CircularProgressIndicator(
                        value: (weekData[selectedDayIndex] / goalValue)
                            .clamp(0.0, 1.0)
                            .toDouble(),
                        backgroundColor: Colors.grey[300],
                        strokeWidth: 8,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          (weekData[selectedDayIndex] > goalValue)
                              ? Colors.red
                              : Colors.deepOrange,
                        ),
                      ),
                    ),
                    Text(
                      (weekData[selectedDayIndex] > goalValue)
                          ? "${formatNumber(weekData[selectedDayIndex] - goalValue)} over"
                          : "${formatNumber(goalValue - weekData[selectedDayIndex])} under",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: List.generate(7, (i) {
                      String dateStr =
                      DateFormat('yyyy-MM-dd').format(weekDates[i]);
                      bool isSelectedDay = dateStr == selectedDayStr;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              child: Text(
                                dayLabels[i],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelectedDay
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: goalValue > 0
                                    ? (weekData[i] / goalValue)
                                    .clamp(0.0, 1.0)
                                    .toDouble()
                                    : 0.0,
                                color: weekData[i] > goalValue
                                    ? Colors.red
                                    : Colors.deepOrange,
                                backgroundColor:
                                Colors.grey[300],
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(width: 8),
                            weekData[i] > goalValue
                                ? Text(
                              "${formatNumber(weekData[i] - goalValue)} over",
                              style:
                              const TextStyle(fontSize: 10, color: Colors.red),
                            )
                                : const SizedBox.shrink(),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String formatNumber(num value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    } else {
      return value.toStringAsFixed(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        backgroundColor: Colors.grey[200],
        body: const Center(child: Text("User not logged in")),
      );
    }

    final formattedDate = DateFormat('EEE, MMM d').format(selectedDate);

    return Scaffold(
      body: Column(
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => _changeDay(-1),
                  icon: const Icon(Icons.arrow_left, size: 32),
                ),
                Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => _changeDay(1),
                  icon: const Icon(Icons.arrow_right, size: 32),
                ),
              ],
            ),
          Expanded(
            child: StreamBuilder<Map<String, dynamic>>(
              stream: _fetchDashboardData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData ||
                    snapshot.data == null ||
                    snapshot.data!.isEmpty) {
                  return const Center(child: Text("No data available"));
                }

                final data = snapshot.data!;
                goals = data['goals'] ?? {};
                weeklyLogs = data['weeklyLogs'] ?? {};

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ListView(
                    children:
                    goals.keys.map((goalType) => _buildGoalCard(goalType)).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
