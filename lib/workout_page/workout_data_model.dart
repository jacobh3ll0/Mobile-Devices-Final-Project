import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutDataModel {
  late String workoutName;
  late String muscleGroup;
  late List<double> weight; // in lbs
  late List<int> reps;
  late DateTime time;
  late DocumentReference? reference;

  WorkoutDataModel({
    required this.workoutName,
    required this.muscleGroup,
    required this.weight,
    required this.reps,
    DateTime? time,
  }) : time = time ?? DateTime.now(); // ensure time as a DateTime

  // Converts a Map object to an instance (pull from database)
  WorkoutDataModel.fromMap(Map<String, dynamic> map, {this.reference}) {
    workoutName = map['workoutName'];
    muscleGroup = map['muscleGroup'];

    List<String> weightList = map['weight'].split(',');

    weight = weightList.map((weight) {
      return double.parse(weight);
    }).toList();

    List<String> repsList = map['reps'].split(',');
    reps = repsList.map((reps) {
      return int.parse(reps);
    }).toList();

    time = DateTime.parse(map['time']);
  }

  // Converts an instance into a Map object (put into database)
  Map<String, dynamic> toMap() {
    return {
      'workoutName': workoutName,
      'muscleGroup': muscleGroup,
      'weight': weight.toString().substring(1, weight.toString().length - 1),
      'reps': reps.toString().substring(1, reps.toString().length - 1),
      'time': time.toString(),
    };
  }
}