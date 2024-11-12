// This set of classes will be used to manage a user's workout data


import 'dart:ffi';

class UserWorkoutCollection {

}

class UserWorkoutDataNode {
  int id;                   // id pulled by database?
  String workoutName;       // name of the workout
  List<Int> reps;           // a list of reps because the user could add an arbitrary amount
  List<Int> sets;           // a list of sets, also arbitrary
  List<bool> setsDone;      // stores whether the user has completed a set

}