import 'dart:developer';

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
    this.workoutName = map['workoutName'];
    this.muscleGroup = map['muscleGroup'];

    List<String> weightList = map['weight'].split(',');

    this.weight = weightList.map((weight) {
      return double.parse(weight);
    }).toList();

    List<String> repsList = map['reps'].split(',');
    this.reps = repsList.map((reps) {
      return int.parse(reps);
    }).toList();

    this.time = DateTime.parse(map['time']);
  }

  // Converts an instance into a Map object (put into database)
  Map<String, dynamic> toMap() {
    return {
      'workoutName': this.workoutName,
      'muscleGroup': this.muscleGroup,
      'weight': this.weight.toString().substring(1, this.weight.toString().length - 1),
      'reps': this.reps.toString().substring(1, this.reps.toString().length - 1),
      'time': this.time.toString(),
    };
  }
}