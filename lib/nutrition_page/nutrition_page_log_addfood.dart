import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NutritionPageLogAddFood extends StatefulWidget {
  final List<Map<String, String>> selectedFoods;

  const NutritionPageLogAddFood({super.key, required this.selectedFoods});

  @override
  _NutritionPageLogAddFoodState createState() =>
      _NutritionPageLogAddFoodState();
}

class _NutritionPageLogAddFoodState extends State<NutritionPageLogAddFood> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, String>> availableFoods = [];
  List<Map<String, String>> selectedFoods = [];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController servingController = TextEditingController();
  final TextEditingController caloriesController = TextEditingController();
  final TextEditingController proteinController = TextEditingController();
  final TextEditingController fatController = TextEditingController();
  final TextEditingController saturatedFatController = TextEditingController();
  final TextEditingController cholesterolController = TextEditingController();
  final TextEditingController sodiumController = TextEditingController();
  final TextEditingController carbohydratesController = TextEditingController();
  final TextEditingController fiberController = TextEditingController();
  final TextEditingController sugarController = TextEditingController();

  List<String> units = ['g', 'ml'];
  String selectedUnit = 'g';

  @override
  void initState() {
    super.initState();
    selectedFoods = List.from(widget.selectedFoods);
    selectedUnit = units.first;
    _fetchAvailableFoods();
  }

  Future<void> _fetchAvailableFoods() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return;
    }
    try {
      final snapshot = await _firestore.collection('users')
          .doc(userId)
          .collection('foods')
          .get();
      setState(() {
        availableFoods = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'].toString(),
            'brand': data['brand'].toString(),
            'serving': data['serving'].toString(),
            'unit': (data['unit'] != null && data['unit'].toString().isNotEmpty) ? data['unit'].toString() : 'g',
            'calories': data['calories'].toString(),
            'protein': data['protein'].toString(),
            'fat': data['fat'].toString(),
            'saturatedFat': data['saturatedFat'].toString(),
            'cholesterol': data['cholesterol'].toString(),
            'sodium': data['sodium'].toString(),
            'carbohydrates': data['carbohydrates'].toString(),
            'fiber': data['fiber'].toString(),
            'sugar': data['sugar'].toString(),
          };
        }).toList();
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load foods. Please try again.'))
      );
    }
  }



  Future<void> _createFood(String unit) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated.')),
      );
      return;
    }

    // Validate required fields
    if (nameController.text.isEmpty ||
        brandController.text.isEmpty ||
        servingController.text.isEmpty ||
        caloriesController.text.isEmpty ||
        proteinController.text.isEmpty ||
        fatController.text.isEmpty ||
        saturatedFatController.text.isEmpty ||
        cholesterolController.text.isEmpty ||
        sodiumController.text.isEmpty ||
        carbohydratesController.text.isEmpty ||
        fiberController.text.isEmpty ||
        sugarController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Please fill in all required fields.', style: const TextStyle(color: Colors.black),), backgroundColor: Colors.grey[200],),
      );
      return;
    }

    // Validate numerical fields
    List<String> numericalFields = [
      'calories',
      'protein',
      'fat',
      'saturatedFat',
      'cholesterol',
      'sodium',
      'carbohydrates',
      'fiber',
      'sugar'
    ];

    for (String field in numericalFields) {
      String value = '';
      switch (field) {
        case 'calories':
          value = caloriesController.text;
          break;
        case 'protein':
          value = proteinController.text;
          break;
        case 'fat':
          value = fatController.text;
          break;
        case 'saturatedFat':
          value = saturatedFatController.text;
          break;
        case 'cholesterol':
          value = cholesterolController.text;
          break;
        case 'sodium':
          value = sodiumController.text;
          break;
        case 'carbohydrates':
          value = carbohydratesController.text;
          break;
        case 'fiber':
          value = fiberController.text;
          break;
        case 'sugar':
          value = sugarController.text;
          break;
        default:
          break;
      }
      if (value.isNotEmpty && double.tryParse(value) == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter valid numbers for $field.')),
        );
        return;
      }
    }

    final Map<String, String> newFood = {
      'name': nameController.text,
      'brand': brandController.text,
      'serving': servingController.text,
      'unit': unit,
      'calories': caloriesController.text,
      'protein': proteinController.text,
      'fat': fatController.text,
      'saturatedFat': saturatedFatController.text,
      'cholesterol': cholesterolController.text,
      'sodium': sodiumController.text,
      'carbohydrates': carbohydratesController.text,
      'fiber': fiberController.text,
      'sugar': sugarController.text,
    };

    try {
      final newFoodRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('foods')
          .add(newFood);
      newFood['id'] = newFoodRef.id; // Add the Firebase-generated ID to the local map.

      setState(() {
        availableFoods.add(Map<String, String>.from(newFood));
      });

      Navigator.pop(context);
      _clearControllers();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create food in Firestore.')),
      );
    }
  }



  void _clearControllers(){
    nameController.clear();
    brandController.clear();
    servingController.clear();
    caloriesController.clear();
    proteinController.clear();
    fatController.clear();
    saturatedFatController.clear();
    cholesterolController.clear();
    sodiumController.clear();
    carbohydratesController.clear();
    fiberController.clear();
    sugarController.clear();
  }

  void _openCreateFoodDialog() {
    // Initialize a local variable for unit selection within the dialog
    String dialogSelectedUnit = selectedUnit;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text("Create New Food"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTextField(nameController, "Food Name"),
                    _buildTextField(brandController, "Brand"),
                    _buildServingAndUnit(dialogSelectedUnit, (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          dialogSelectedUnit = newValue;
                        });
                      }
                    }),
                    _buildTextField(
                      caloriesController,
                      "Calories",
                      keyboardType: TextInputType.number,
                    ),
                    _buildTextField(
                      proteinController,
                      "Protein (g)",
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    _buildTextField(
                      fatController,
                      "Fat (g)",
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    _buildTextField(
                      saturatedFatController,
                      "Saturated Fat (g)",
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    _buildTextField(
                      cholesterolController,
                      "Cholesterol (mg)",
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    _buildTextField(
                      sodiumController,
                      "Sodium (mg)",
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    _buildTextField(
                      carbohydratesController,
                      "Carbohydrates (g)",
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    _buildTextField(
                      fiberController,
                      "Fiber (g)",
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    _buildTextField(
                      sugarController,
                      "Sugar (g)",
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ],

                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    // Update the main widget's selectedUnit to the dialog's selection
                    setState(() {
                      selectedUnit = dialogSelectedUnit;
                    });
                    _createFood(dialogSelectedUnit);
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
      },
    );
  }

  Future<void> _deleteFood(String foodId, int index) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    try {
      await _firestore.collection('users').doc(userId).collection('foods').doc(foodId).delete();
      setState(() {
        availableFoods.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Food deleted successfully', style: const TextStyle(color: Colors.black),), backgroundColor: Colors.grey[200],),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete food.'))
      );
    }
  }


  void _openEditFoodDialog(Map<String, String> food, int index) {
    final TextEditingController servingController = TextEditingController(text: food['serving']);
    String currentUnit = food['unit'] ?? 'g';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Serving Size'),
          content: TextField(
            controller: servingController,
            decoration: InputDecoration(
              labelText: 'Enter new serving size ($currentUnit)',
              border: const OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                final newServingSize = servingController.text;
                if (newServingSize.isNotEmpty && double.tryParse(newServingSize) != null) {
                  _updateFoodServing(food, newServingSize, currentUnit, index);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: const Text('Please enter a valid serving size', style: const TextStyle(color: Colors.black),), backgroundColor: Colors.grey[200],),
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
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _updateFoodServing(Map<String, String> food, String newServingSize, String newUnit, int index) {
    double newServing = double.tryParse(newServingSize) ?? 0.0;
    double oldServing = double.tryParse(food['serving']!) ?? 1.0;
    double ratio = newServing / oldServing;

    // Update food details proportionally
    food['serving'] = newServingSize;
    food['calories'] = (double.parse(food['calories']!) * ratio).toStringAsFixed(0);
    food['protein'] = (double.parse(food['protein']!) * ratio).toStringAsFixed(0);
    food['fat'] = (double.parse(food['fat']!) * ratio).toStringAsFixed(0);
    food['saturatedFat'] = (double.parse(food['saturatedFat']!) * ratio).toStringAsFixed(0);
    food['cholesterol'] = (double.parse(food['cholesterol']!) * ratio).toStringAsFixed(0);
    food['sodium'] = (double.parse(food['sodium']!) * ratio).toStringAsFixed(0);
    food['carbohydrates'] = (double.parse(food['carbohydrates']!) * ratio).toStringAsFixed(0);
    food['fiber'] = (double.parse(food['fiber']!) * ratio).toStringAsFixed(0);
    food['sugar'] = (double.parse(food['sugar']!) * ratio).toStringAsFixed(0);

    final userId = FirebaseAuth.instance.currentUser?.uid;
    _firestore.collection('users').doc(userId).collection('foods').doc(food['id']).update(food)
        .then((_) {
      setState(() {
        availableFoods[index] = Map<String, String>.from(food);  // Update local state
      });
    })
        .catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update food in Firestore.'))
      );
    });
  }


  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
      ),
    );
  }

  Widget _buildServingAndUnit(String currentUnit, Function(String?) onUnitChanged) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: servingController,
            decoration: InputDecoration(
              labelText: "Serving ($currentUnit)",
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 1,
          child: DropdownButtonFormField<String>(
            value: currentUnit,
            decoration: const InputDecoration(
              labelText: 'Unit',
              border: OutlineInputBorder(),
            ),
            onChanged: onUnitChanged,
            dropdownColor: Colors.grey[200],
            items: units.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: const TextStyle(color: Colors.black),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Food"),
      ),
      body: Column(
        children: [
          Expanded(
            child: availableFoods.isEmpty
                ? Center(
              child: Text(
                "No foods available.",
                style: TextStyle(fontSize: 16, color: Colors.grey[400]),
              ),
            )
                : ListView.builder(
              itemCount: availableFoods.length,
              itemBuilder: (context, index) {
                final food = availableFoods[index];
                return Dismissible(
                  key: Key(food['id']!),
                  background: Container(
                    color: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerRight,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    _deleteFood(food['id']!, index);
                  },
                  child: InkWell(
                    onLongPress: () {
                      _openEditFoodDialog(food, index);
                    },
                    child: CheckboxListTile(
                      title: Text('${food['name']} - ${food['brand']}'),
                      subtitle: Text('Serving: ${food['serving']}${food['unit']}'), // Display unit correctly
                      value: selectedFoods.contains(food),
                      onChanged: (bool? selected) {
                        setState(() {
                          if (selected ?? false) {
                            selectedFoods.add(food);
                          } else {
                            selectedFoods.remove(food);
                          }
                        });
                      },
                    ),


                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _openCreateFoodDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28.0),
                    ),
                  ),
                  child: const Text("Create Food"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, selectedFoods),
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
            ),
          ),
        ],
      ),
    );
  }
}