import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NutritionPageLogAddFood extends StatefulWidget {
  final List<Map<String, String>> selectedFoods;

  NutritionPageLogAddFood({required this.selectedFoods});

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

  @override
  void initState() {
    super.initState();
    selectedFoods = List.from(widget.selectedFoods);
    _fetchAvailableFoods();
  }

  Future<void> _fetchAvailableFoods() async {
    try {
      final snapshot = await _firestore.collection('foods').get();
      setState(() {
        availableFoods = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'name': data['name']?.toString() ?? '',
            'brand': data['brand']?.toString() ?? '',
            'serving': data['serving']?.toString() ?? '',
            'calories': data['calories']?.toString() ?? '0',
            'protein': data['protein']?.toString() ?? '0',
            'fat': data['fat']?.toString() ?? '0',
            'saturatedFat': data['saturatedFat']?.toString() ?? '0',
            'cholesterol': data['cholesterol']?.toString() ?? '0',
            'sodium': data['sodium']?.toString() ?? '0',
            'carbohydrates': data['carbohydrates']?.toString() ?? '0',
            'fiber': data['fiber']?.toString() ?? '0',
            'sugar': data['sugar']?.toString() ?? '0',
          };
        }).toList();
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load foods. Please try again.')),
      );
    }
  }

  Future<void> _createFood() async {
    final Map<String, String> food = {
      'name': nameController.text,
      'brand': brandController.text,
      'serving': servingController.text,
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

    Navigator.pop(context);

    setState(() {
      availableFoods.add(food);
    });

    _clearControllers();

    try {
      final newFoodRef = await _firestore.collection('foods').add(food);
      int index = availableFoods.indexOf(food);
      availableFoods[index]['id'] = newFoodRef.id;
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create food in Firestore.'))
      );
    }
  }


  void _clearControllers() {
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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Create New Food"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(nameController, "Food Name"),
                _buildTextField(brandController, "Brand"),
                _buildTextField(servingController, "Serving"),
                _buildTextField(caloriesController, "Calories"),
                _buildTextField(proteinController, "Protein (g)"),
                _buildTextField(fatController, "Fat (g)"),
                _buildTextField(saturatedFatController, "Saturated Fat (g)"),
                _buildTextField(cholesterolController, "Cholesterol (mg)"),
                _buildTextField(sodiumController, "Sodium (mg)"),
                _buildTextField(carbohydratesController, "Carbohydrates (g)"),
                _buildTextField(fiberController, "Fiber (g)"),
                _buildTextField(sugarController, "Sugar (g)"),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: _createFood,
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

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Food"),
      ),
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          Expanded(
            child: availableFoods.isEmpty
                ? Center(
              child: Text(
                "No foods available.",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            )
                : ListView.builder(
              itemCount: availableFoods.length,
              itemBuilder: (context, index) {
                final food = availableFoods[index];
                return CheckboxListTile(
                  title: Text(food['name'] ?? 'Unknown Food'),
                  subtitle: Text(food['brand'] ?? 'Unknown Brand'),
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
                    backgroundColor: Colors.lightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28.0),
                    ),
                  ),
                  child: Text("Create Food"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, selectedFoods),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28.0),
                    ),
                  ),
                  child: Text("Submit"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
