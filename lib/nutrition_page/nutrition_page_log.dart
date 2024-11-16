import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'nutrition_page_log_addfood.dart';

class NutritionPageLog extends StatefulWidget {
  @override
  _NutritionPageLogState createState() => _NutritionPageLogState();
}

class _NutritionPageLogState extends State<NutritionPageLog> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Future<void> _fetchMealLogs() async {
    for (var mealType in meals.keys) {
      final snapshot = await _firestore
          .collection('mealLogs')
          .doc('userID')
          .collection('meals')
          .doc(mealType)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data();

        setState(() {
          meals[mealType] = (data?['foods'] as List<dynamic>?)
              ?.map((food) => Map<String, String>.from(food as Map))
              .toList() ??
              [];
        });
      }
    }
  }

  Future<void> _updateMeal(String mealType, List<Map<String, String>> foods) async {
    await _firestore
        .collection('mealLogs')
        .doc('userID')
        .collection('meals')
        .doc(mealType)
        .set({
      'type': mealType,
      'calories': foods.fold(
          0, (sum, food) => sum + int.parse(food['calories'] ?? '0')),
      'foods': foods,
    });

    setState(() {
      meals[mealType] = foods;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: ListView(
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    "${meals[mealType]?.fold(0, (sum, food) => sum + int.parse(food['calories'] ?? '0'))} calories",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Column(
                    children: meals[mealType]?.map((food) {
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(food['name'] ?? 'Unknown Food'),
                        subtitle: Text(food['brand'] ?? 'Unknown Brand'),
                        trailing: Text("${food['calories']} cal"),
                      );
                    }).toList() ?? [],
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: () async {
                        final selectedFoods = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NutritionPageLogAddFood(
                              selectedFoods: meals[mealType] ?? [],
                            ),
                          ),
                        );

                        if (selectedFoods != null) {
                          _updateMeal(mealType, selectedFoods);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28.0),
                        ),
                      ),
                      child: Text("Add Food"),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
