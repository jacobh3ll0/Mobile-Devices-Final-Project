// this class will contain the structure of how we handle workouts / exercises
// for example, push-ups may look like this:
//
// workoutId = 25
// workoutName = "Push-ups"
// muscleWikiURL = "... an actual URL"
// muscleGroup = "Chest"

class ExerciseData {
  int workoutId; //Primary key,
  String workoutName;
  String? muscleWikiURL;
  String? muscleGroup;

  ExerciseData({required this.workoutId, required this.workoutName});
}