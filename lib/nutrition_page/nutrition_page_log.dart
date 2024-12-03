import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'nutrition_page_log_addfood.dart';
import 'package:intl/intl.dart';

/// Manages the meal logs, allowing users to view and update their meals for selected dates.
class NutritionPageLog extends StatefulWidget {
  const NutritionPageLog({super.key});

  @override
  NutritionPageLogState createState() => NutritionPageLogState();
}

class NutritionPageLogState extends State<NutritionPageLog> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime selectedDate = DateTime.now();

  Map<String, List<Map<String, String>>> meals = {
    'Breakfast': [],
    'Lunch': [],
    'Dinner': [],
    'Snacks': [],
  };

  @override
  void initState() {
    super.initState();
    _fetchMealLogs();
  }

  /// Fetches meal logs for the selected date from Firestore.
  Future<void> _fetchMealLogs() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return;
    }

    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('mealLogs')
        .where('date', isEqualTo: formattedDate)
        .get();

    Map<String, List<Map<String, String>>> newMeals = {
      'Breakfast': [],
      'Lunch': [],
      'Dinner': [],
      'Snacks': [],
    };

    for (var doc in snapshot.docs) {
      var mealData = doc.data() as Map<String, dynamic>;
      newMeals[mealData['type']] = (mealData['foods'] as List<dynamic>?)
          ?.map((food) => Map<String, String>.from(food as Map))
          .toList() ??
          [];
    }

    setState(() {
      meals = newMeals;
    });
  }

  /// Updates a specific meal with the provided list of foods.
  Future<void> _updateMeal(
      String mealType, List<Map<String, String>> foods) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return;
    }

    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    try {
      int totalCalories =
      foods.fold(0, (sum, food) => sum + int.parse(food['calories'] ?? '0'));
      double totalProtein = foods.fold(
          0.0, (sum, food) => sum + double.parse(food['protein'] ?? '0'));
      double totalFat = foods.fold(
          0.0, (sum, food) => sum + double.parse(food['fat'] ?? '0'));
      double totalCarbs = foods.fold(
          0.0, (sum, food) => sum + double.parse(food['carbohydrates'] ?? '0'));
      double totalFiber = foods.fold(
          0.0, (sum, food) => sum + double.parse(food['fiber'] ?? '0'));
      double totalSaturatedFat = foods.fold(
          0.0,
              (sum, food) =>
          sum + double.parse(food['saturatedFat'] ?? '0'));
      double totalCholesterol = foods.fold(
          0.0, (sum, food) => sum + double.parse(food['cholesterol'] ?? '0'));
      double totalSugar = foods.fold(
          0.0, (sum, food) => sum + double.parse(food['sugar'] ?? '0'));
      double totalSodium = foods.fold(
          0.0, (sum, food) => sum + double.parse(food['sodium'] ?? '0'));

      DocumentReference docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('mealLogs')
          .doc('$mealType-$formattedDate');

      await docRef.set({
        'type': mealType,
        'calories': totalCalories,
        'protein': totalProtein,
        'fat': totalFat,
        'carbohydrates': totalCarbs,
        'fiber': totalFiber,
        'saturatedFat': totalSaturatedFat,
        'cholesterol': totalCholesterol,
        'sugar': totalSugar,
        'sodium': totalSodium,
        'foods': foods,
        'date': formattedDate,
      });

      setState(() {
        meals[mealType] = foods;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$mealType updated successfully', style: const TextStyle(color: Colors.black),), backgroundColor: Colors.grey[200],),
      );
    } catch (error) {
      log("Error updating meal: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update meal. Please try again.', style: TextStyle(color: Colors.white),), backgroundColor: Colors.red,),
      );
    }
  }

  /// Changes the selected date by the specified number of days and fetches new meal logs.
  void _changeDate(int days) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: days));
      _fetchMealLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEE, MMM d').format(selectedDate);

    return Scaffold(
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => _changeDate(-1),
                icon: const Icon(Icons.arrow_left, size: 32),
              ),
              Text(
                formattedDate,
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => _changeDate(1),
                icon: const Icon(Icons.arrow_right, size: 32),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              children: meals.keys.map((mealType) {
                return Card(
                  elevation: 4.0,
                  margin: const EdgeInsets.all(8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mealType,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          "${meals[mealType]?.fold(0, (sum, food) => sum + int.parse(food['calories'] ?? '0'))} calories",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Column(
                          children: meals[mealType]?.map((food) {
                            return Dismissible(
                              key: Key(food['id']!),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) {
                                meals[mealType]?.remove(food);
                                _updateMeal(mealType, meals[mealType]!);
                              },
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20),
                                child: const Icon(Icons.delete,
                                    color: Colors.white),
                              ),
                              child: ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title:
                                Text('${food['name']} - ${food['brand']}'),
                                subtitle:
                                Text('${food['serving']}${food['unit']}'),
                                trailing:
                                Text("${food['calories']} cal"),
                              ),
                            );
                          }).toList() ??
                              [],
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: ElevatedButton(
                            onPressed: () async {
                              final selectedFoods = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      NutritionPageLogAddFood(
                                        selectedFoods: meals[mealType] ?? [],
                                      ),
                                ),
                              );

                              if (selectedFoods != null) {
                                _updateMeal(mealType, selectedFoods);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28.0),
                              ),
                            ),
                            child: const Text("Add Food"),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
