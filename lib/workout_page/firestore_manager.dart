import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:md_final/workout_page/workout_data_model.dart';

class FirestoreManager {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final String uid;

  FirestoreManager() {
    User? user = FirebaseAuth.instance.currentUser; //Gets the current user information from the FireBase (Could be null in case of error)
    uid = user != null ? user.uid : "error getting user"; //Set either user Email, or null (if error)
  }

  Future<void> storeUserData(Map<String, dynamic> userData) async {

    //connect to FireStore database
    await _firestore.collection('users').doc(uid).collection('workoutData').add(userData);

  }

  Future<List<String>> getKeysForGroupedByDay() async {

    List<WorkoutDataModel> userDataList = await getUserData(false);
    //for each entry in user data, group it together
    Map<String, List<WorkoutDataModel>> maps = {};
    for(int i = 0; i < userDataList.length; i++) {

      //extract time from the map
      DateTime time = userDataList[i].time;

      //get current date
      String mapKey = "${time.year}-${time.month}-${time.day}";
      if(maps.containsKey(mapKey)) {
        maps[mapKey]?.add(userDataList[i]);
      } else {
        //doesn't contain key, so make it
        maps[mapKey] = [userDataList[i]];
      }
    }

    return maps.keys.toList();
  }

  Future<List<WorkoutDataModel>> getUserData(bool keepOnlyToday) async {
    // log("fetching userdata", name: "firestore manager");
    final QuerySnapshot<Map<String, dynamic>> userData;
    List<Map<String, dynamic>> maps = [];
    List<WorkoutDataModel> userDataList = [];

    if(keepOnlyToday) {
      userData = await FirebaseFirestore.instance.collection('users').doc(uid).collection('workoutData').orderBy('time', descending: true).get();

      DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

      for (var workout in userData.docs) {
        DateTime workoutTime = DateTime.parse(workout.data()["time"].toString());
        DateTime compareDateTime = DateTime(workoutTime.year, workoutTime.month, workoutTime.day);
        if(compareDateTime == today) {
          maps.add(workout.data());
        }
      }


    } else {

      userData = await FirebaseFirestore.instance.collection('users').doc(uid).collection('workoutData').get();
      for (var workout in userData.docs) {
        maps.add(workout.data());
      }

      // log("maps: $maps");
    }
    for (int i = 0; i < maps.length; i++) {
      userDataList.add(WorkoutDataModel.fromMap(maps[i], reference: userData.docs[i].reference));
    }

    return userDataList;
  }

  Future<List<List<WorkoutDataModel>>> getUserDataGroupedByWorkoutName() async {
    List<WorkoutDataModel> userDataList = await getUserData(true);
    //for each entry in user data, group it together
    Map<String, List<WorkoutDataModel>> maps = {};
    for(int i = 0; i < userDataList.length; i++) {
      if(maps.containsKey(userDataList[i].workoutName)) {
        maps[userDataList[i].workoutName]?.add(userDataList[i]);
      } else {
        //doesn't contain key, so make it
        maps[userDataList[i].workoutName] = [userDataList[i]];
      }
    }

    // convert map to List<List<WorkoutDataModel>>
    // this also groups the data by workout name
    List<List<WorkoutDataModel>> returnData = [];
    for (var val in maps.values) {
      returnData.add(val);
    }

    return returnData;
  }

  Future<List<List<WorkoutDataModel>>> getUserDataGroupedByDay() async {

    List<WorkoutDataModel> userDataList = await getUserData(false);

    //for each entry in user data, group it together
    Map<String, List<WorkoutDataModel>> maps = {};
    for(int i = 0; i < userDataList.length; i++) {
      // log(userDataList[i].toString());

      DateTime time = userDataList[i].time;

      //get current date
      String mapKey = "${time.year}-${time.month}-${time.day}";
      if(maps.containsKey(mapKey)) {
        maps[mapKey]?.add(userDataList[i]);
      } else {
        //doesn't contain key, so make it
        maps[mapKey] = [userDataList[i]];
      }
    }

    // convert map to List<List<WorkoutDataModel>>
    // this also groups the data by workout name
    List<List<WorkoutDataModel>> returnData = [];
    for (var val in maps.values) {
      // log("data: $val");
      returnData.add(val);
    }

    returnData.sort((a, b) => b[0].time.compareTo(a[0].time));

    return returnData;
  }

  Future<void> deleteWorkoutById(String workoutId) async {
    log("$workoutId deleted", name: "Firestore Manager");
    await FirebaseFirestore.instance.collection('users').doc(uid).collection('workoutData').doc(workoutId).delete();
  }

}