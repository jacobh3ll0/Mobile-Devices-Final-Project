import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreManager {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final String uid;

  FirestoreManager() {
    User? user = FirebaseAuth.instance.currentUser; //Gets the current user information from the FireBase (Could be null in case of error)
    uid = user != null ? user.uid : "error getting user"; //Set either user Email, or null (if error)
  }

  Future<void> storeUserData(Map<String, dynamic> userData) async {

    //connect to FireStore database
    await _firestore.collection('users').doc(uid).set(userData);

  }

  getUserData() {

  }

}