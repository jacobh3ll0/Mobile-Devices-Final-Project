import 'package:flutter/material.dart';
import 'package:md_final/workout_page/active_workout_firebase_display.dart';
import 'package:md_final/workout_page/build_bottom_app_bar_workout_page.dart';
import 'package:md_final/workout_page/create_new_workout_page.dart';
import 'package:md_final/workout_page/firestore_manager.dart';
import 'package:md_final/workout_page/workout_data_model.dart';

class NavigateToPastWorkouts extends StatefulWidget {
  const NavigateToPastWorkouts({super.key});

  @override
  State<NavigateToPastWorkouts> createState() => _NavigateToPastWorkoutsState();
}

class _NavigateToPastWorkoutsState extends State<NavigateToPastWorkouts> {
  @override
  Widget build(BuildContext context) {

    FirestoreManager manager = FirestoreManager();

    return Scaffold(
      body: FutureBuilder<List<List<WorkoutDataModel>>>(
        future: manager.getUserDataGroupedByDay(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator()); // Show loading indicator while fetching data
          }
          //display workout data
          if(snapshot.data == null || snapshot.data!.isEmpty) {
            return  Scaffold(
              appBar: AppBar(title: const Text("Workout")),
              body: const Center(
                child: Text(
                  'No workouts found. Start by adding one using the "+" button!',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return Scaffold(
            appBar: AppBar(title: const Text("Workout")),
            // body: Container(color: Colors.blue,),
            body: ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                var userWorkout = snapshot.data![index]; // Getting the current person from the list
                return _buildIndividualWorkout(userWorkout, snapshot, index, context, manager);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push( //returns a Grade object
              context,
              MaterialPageRoute(
                builder: (context) => const CreateNewWorkoutPage(),
              )
          );
          if(result != null) {
            setState(() {
              manager.storeUserData(result.toMap());
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );

  }

  Widget _buildIndividualWorkout(List<WorkoutDataModel> userWorkout, AsyncSnapshot<List<List<WorkoutDataModel>>> snapshot,
      int index, BuildContext context, FirestoreManager manager) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
          title: Text("${userWorkout[0].time.year}-${userWorkout[0].time.month}-${userWorkout[0].time.day}"),
          initiallyExpanded: true,
          // subtitle: Text('Muscle Group: ${userWorkout.muscleGroup}'),
          children: _buildExpansionTileChildren(userWorkout, snapshot, index, context, manager)
      ),
    );

  }

  List<Widget> _buildExpansionTileChildren(List<WorkoutDataModel> userWorkout, AsyncSnapshot<List<List<WorkoutDataModel>>> snapshot, int index, BuildContext context, FirestoreManager manager) {
    List<Widget> returnWidgets = [];

    for(var workout in userWorkout) {
      returnWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Details:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("Name: ${workout.workoutName}"),
              Text('Weight: ${workout.weight} lbs'),
              Text('Reps: ${workout.reps}'),
              Text('Date: ${workout.time.toLocal().toString().split(' ')[0]}'),
              Text("Date: ${workout.time.toString()}"),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {

                    },
                    icon: const Icon(Icons.edit, color: Colors.blue),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        snapshot.data?.removeAt(index); //remove widget from tree
                      });
                      manager.deleteWorkoutById(workout.reference!.id);
                      _showSnackBar(context, '${workout.workoutName} deleted');

                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    return returnWidgets;

  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context) // show snack bar
        .showSnackBar(SnackBar(content: Text(message)));
  }
}