//flutter packages
import 'dart:developer';
import 'package:flutter/material.dart';

//my packages
import 'package:md_final/workout_page/clock_widget.dart';
import 'package:md_final/workout_page/firestore_manager.dart';
import 'package:md_final/workout_page/small_text_popup.dart';
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
            title: _buildStartOrEndButton(manager),
            centerTitle: true,
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

  Widget _buildStartOrEndButton(FirestoreManager manager) {

    //must use FutureBuilder because of the call to firebase if the time is there or not
    return FutureBuilder<bool>(
      future: manager.doesTimeExist(), // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.hasData) {
          if(!snapshot.data!) {

            //time is not in database, thus no workout
            return ElevatedButton(onPressed: () {
              //Store time in db
              setState(() {
                manager.storeCurrentTime();
              });

              }, child: const Text("Start Workout"),);

          } else { // time in database

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(onPressed: () {
                  setState(() {
                    manager.deleteTime();
                  });
                  }, child: const Text("End Workout"),),
                _buildClockWidgetFuture(manager),
              ],
            );
          }
        } else if (snapshot.hasError) {
          return const Center(child: Text("Error fetching from Firebase"),);

        } else { //loading
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildClockWidgetFuture(FirestoreManager manager) {
    return FutureBuilder(
      future: manager.readTime(),
      builder: (BuildContext context, AsyncSnapshot<DateTime> snapshot) {
        if (snapshot.hasData) {
          return ClockWidget(time: snapshot.data!,);

        } else if (snapshot.hasError) {
          return const Center(child: Text("Error fetching from Firebase"),);

        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildIndividualWorkout(List<WorkoutDataModel> userWorkout, AsyncSnapshot<List<List<WorkoutDataModel>>> snapshot,
      int index, BuildContext context, FirestoreManager manager) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Icon(Icons.fitness_center, color: Theme.of(context).colorScheme.primary),
        title: Text(
          userWorkout[0].workoutName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          "Total Sets: ${userWorkout.length}",
          style: const TextStyle(color: Colors.blueGrey),
        ),
        children: _buildExpansionTileChildren(
          userWorkout,
          snapshot,
          index,
          context,
          manager,
        ),
      ),
    );
  }

  List<Widget> _buildExpansionTileChildren(List<WorkoutDataModel> userWorkout, AsyncSnapshot<List<List<WorkoutDataModel>>> snapshot,
      int index, BuildContext context, FirestoreManager manager,) {
    List<Widget> returnWidgets = [];

    for (var workout in userWorkout) {

      returnWidgets.add(
          buildRepsAndWeightsGrid(workout.reps, workout.weight)
      );

      returnWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  var userInput = await showNumberDialog(context);
                  if (userInput != null) {
                    setState(() {
                      workout.reps.add(double.parse(userInput["intNumber"].toString()).toInt());
                      workout.weight.add(userInput["floatNumber"]!);
                      manager.editGrade(workout.reference!.id, workout);
                    });
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text("Add Set"),
              ),
              IconButton(onPressed: () {
                setState(() {
                  snapshot.data?.removeAt(index); //remove widget from tree
                });
                manager.deleteWorkoutById(workout.reference!.id);
                _showSnackBar(context, '${workout.workoutName} deleted');
                }, icon: const Icon(Icons.delete, color: Colors.redAccent,))
            ],
          ),
        ),
      );
    }

    return returnWidgets;
  }

  Widget buildRepsAndWeightsGrid(List<int> reps, List<double> weights) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemCount: reps.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 3,
          margin: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Set ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("Reps: ${reps[index]}"),
              Text("Weight: ${weights[index]} lbs"),
            ],
          ),
        );
      },
    );

    GridView.count(
      primary: false,
      padding: const EdgeInsets.all(20),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: 2,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.teal[100],
          child: const Text("He'd have you all unravel at the"),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.teal[200],
          child: const Text('Heed not the rabble'),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.teal[300],
          child: const Text('Sound of screams but the'),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.teal[400],
          child: const Text('Who scream'),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.teal[500],
          child: const Text('Revolution is coming...'),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.teal[600],
          child: const Text('Revolution, they...'),
        ),
      ],
    );
  }




  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context) // show snack bar
        .showSnackBar(SnackBar(content: Text(message)));
  }
}