import 'package:flutter/material.dart';
import 'package:md_final/workout_page/workout_data_model.dart';

class CreateNewWorkoutPage extends StatefulWidget {
  const CreateNewWorkoutPage({super.key});

  @override
  State<CreateNewWorkoutPage> createState() => _CreateNewWorkoutPageState();
}

class _CreateNewWorkoutPageState extends State<CreateNewWorkoutPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _workoutNameController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  String? _selectedMuscleGroup;

  final List<String> _muscleGroups = [ //for user to select a muscle group, (in future a custom option to add there own will be there)
    'Chest',
    'Back',
    'Legs',
    'Shoulders',
    'Arms',
    'Core'
  ]; //perhaps we can grab these from a central database

  @override
  void dispose() {
    _workoutNameController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _saveWorkout(BuildContext context) {
    if (_formKey.currentState!.validate()) { //attempt to validate form
      WorkoutDataModel workout = WorkoutDataModel(
          workoutName: _workoutNameController.text,
          muscleGroup: _selectedMuscleGroup!,
          weight: double.parse(_repsController.text),
          reps: int.parse(_weightController.text),
      );
      Navigator.pop(context, workout); // Return the workout object to the previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Workout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), //gives nice border
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Workout Name (in future this will match against a database)
              TextFormField(
                controller: _workoutNameController,
                decoration: const InputDecoration(
                  labelText: 'Workout Name',
                  border: OutlineInputBorder(),
                ),
                validator: _workoutNameValidator
              ),
              const SizedBox(height: 16),

              // Dropdown for muscle group (may need to add more in future, or a custom option)
              DropdownButtonFormField<String>(
                value: _selectedMuscleGroup,
                decoration: const InputDecoration(
                  labelText: 'Muscle Group',
                  border: OutlineInputBorder(),
                ),
                items: _muscleGroups.map((group) {
                  return DropdownMenuItem(
                    value: group,
                    child: Text(group),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMuscleGroup = value;
                  });
                },
                validator: _muscleGroupValidator,
              ),
              const SizedBox(height: 16),

              // Reps field
              TextFormField(
                controller: _repsController,
                decoration: const InputDecoration(
                  labelText: 'Reps',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: _repsValidator
              ),
              const SizedBox(height: 16),

              // Weight field
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Weight (lbs)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: _weightValidator
              ),
              const SizedBox(height: 16),

              // Save Button
              ElevatedButton(
                onPressed: () {_saveWorkout(context);},
                child: const Text('Save Workout'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _workoutNameValidator(value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a workout name';
    }
    return null;
  }

  String? _muscleGroupValidator(value) {
    if (value == null || value.isEmpty) {
      return 'Please select a muscle group';
    }
    return null;
  }

  String? _repsValidator(value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the number of reps';
    }
    if (int.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  String? _weightValidator(value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the weight';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }
}
