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

  Future<List<WorkoutDataModel>> getUserData() async {
    // log("fetching userdata", name: "firestore manager");
    final userData = await FirebaseFirestore.instance.collection('users').doc(uid).collection('workoutData').get();

    // final List<Map<String, dynamic>> maps = await database.query('userData');
    List<Map<String, dynamic>> maps = [];

    for (var workout in userData.docs) {
      maps.add(workout.data());
    }

    List<WorkoutDataModel> userDataList = [];
    for (int i = 0; i < maps.length; i++) {
      userDataList.add(WorkoutDataModel.fromMap(maps[i], reference: userData.docs[i].reference));
    }

    return userDataList;
  }

  Future<List<List<WorkoutDataModel>>> getUserDataGroupedByWorkoutName() async {
    List<WorkoutDataModel> userDataList = await getUserData();
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
      // log("data: $val");
      returnData.add(val);
    }

    return returnData;
  }

  Future<void> deleteWorkoutById(String workoutId) async {
    log("$workoutId deleted", name: "Firestore Manager");
    await FirebaseFirestore.instance.collection('users').doc(uid).collection('workoutData').doc(workoutId).delete();
  }

}