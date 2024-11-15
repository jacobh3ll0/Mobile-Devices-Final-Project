class WorkoutDataModel {
  late String workoutName;
  late String muscleGroup;
  late double weight; // in lbs
  late int reps;
  late DateTime time;

  WorkoutDataModel({
    required this.workoutName,
    required this.muscleGroup,
    required this.weight,
    required this.reps,
    DateTime? time,
  }) : time = time ?? DateTime.now(); // ensure time as a DateTime

  // Converts a Map object to an instance
  WorkoutDataModel.fromMap(Map<String, dynamic> map) {
    this.workoutName = map['workoutName'];
    this.muscleGroup = map['muscleGroup'];
    this.weight = map['weight'];
    this.reps = map['reps'];
    this.time = DateTime.parse(map['time']);
  }

  // Converts an instance into a Map object
  Map<String, dynamic> toMap() {
    return {
      'workoutName': this.workoutName,
      'muscleGroup': this.muscleGroup,
      'weight': this.weight,
      'reps': this.reps,
      'time': this.time.toString(),
    };
  }

}