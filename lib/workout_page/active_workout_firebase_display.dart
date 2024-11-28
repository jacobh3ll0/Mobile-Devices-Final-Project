import 'package:flutter/material.dart';
import 'package:flutter_animate/adapters/change_notifier_adapter.dart';
import 'package:md_final/workout_page/clock_widget.dart';
import 'package:md_final/workout_page/firestore_manager.dart';
import 'package:md_final/workout_page/workout_data_model.dart';


class FirebaseFetcher extends StatefulWidget {
  const FirebaseFetcher({super.key, required this.manager});

  final FirestoreManager manager;

  @override
  State<FirebaseFetcher> createState() => _FirebaseFetcherState();
}

class _FirebaseFetcherState extends State<FirebaseFetcher> {
  @override
  Widget build(BuildContext context) {

    FirestoreManager manager = widget.manager;

    return FutureBuilder<List<List<WorkoutDataModel>>>(
        future: manager.getUserDataGroupedByWorkoutName(),
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
            appBar: AppBar(
              // title: const Text("Workout"),
              title: ElevatedButton(onPressed: () {}, child: Text("Start Workout"),), centerTitle: true,
              actions: const [
                ClockWidget()
              ],
            ),
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
      );

  }

  Widget _buildIndividualWorkout(List<WorkoutDataModel> userWorkout, AsyncSnapshot<List<List<WorkoutDataModel>>> snapshot,
      int index, BuildContext context, FirestoreManager manager) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
          title: Text(userWorkout[0].workoutName),
          enableFeedback: true,
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
              //lbs and edit button, reps and edit button, checkbox
              //TODO

              const Text('Details:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Weight: ${workout.weight} lbs'),
              Text('Reps: ${workout.reps}'),
              Text('Date: ${workout.time.toLocal().toString().split(' ')[0]}'),
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