import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

//This page handles adding a reply to the replies page

class ReplyPage extends StatefulWidget
{
  final String originalPostDescription; //Text of original post
  final String postId; //Id of the post

  const ReplyPage({
    super.key,
    required this.originalPostDescription,
    required this.postId,
  });

  @override
  ReplyPageState createState() => ReplyPageState();
}

class ReplyPageState extends State<ReplyPage> {
  String userDisplayName = ""; //Users display name for comment
  String userProfileImage = ""; //Users PFP for comment
  final TextEditingController _replyController = TextEditingController(); //Reply input controller

  @override
  void initState() {
    super.initState();
    fetchUserData(); //Get the current users data when the page loads
  }


  Future<void> fetchUserData() async //Function to get user data
  {
    try
    {
      User? user = FirebaseAuth.instance
          .currentUser; //Get current user using token

      if (user != null)
      {
        String uid = user.uid; //set user uid
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get(); //Use uid to query database

        if (userDoc.exists) //Make sure user exists and grab info
          {
          setState(() {
            userDisplayName = userDoc['displayName'] ?? "Unknown User"; //If the name cant be found, set unknown (Should not happen)
            userProfileImage = userDoc['profileImageURL'] ?? ""; //If PFP not found, set to no profile picture
          });
        }
      }
    }
    catch (e) //Output an error via snackbar
        {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to load user from database!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _submitReply() async //Function which handles submitting the reply
      {
    final replyText = _replyController.text;

    if (replyText.isNotEmpty) //Make sure reply is not empty
        {
      try {
        //Add the reply data to the firebase
        await FirebaseFirestore.instance.collection('socialReplies').add({
          'postId': widget.postId,
          'userDisplayName': userDisplayName,
          'userProfileImageURL': userProfileImage,
          'description': replyText,
          'timeString': DateTime.now().toIso8601String(), //Iso format for date sort efficiency
        });

        //Increment the comment count of the post commenting to
        final postRef = FirebaseFirestore.instance.collection('socialPosts').doc(widget.postId);
        await postRef.update({
          'numComments': FieldValue.increment(1)
        }); //Increment the comment count by 1

        Navigator.pop(
            context, true); //Return a reply success to post replies page
      }
      catch (e) //Give error to user if database save fails
          {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to connect to database!"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    else
    {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Reply must contain something!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  //Definition of page layout
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reply to Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            //Show text of post being replied to
            const Text(
              'Original Post:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '"${widget.originalPostDescription}"',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),

            const SizedBox(height: 40),

            //Text input for reply
            TextField(
              controller: _replyController,
              decoration: const InputDecoration(
                labelText: 'Your reply',
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey, //Grey border when not focused
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue, //Blue border when focused
                    width: 2.0,
                  ),
                ),
              ),
              maxLines: 5, //Allow up to 5 lines for the reply input
            ),

            const SizedBox(height: 20),

            //Submit reply button
            Center(
              child: ElevatedButton(
                onPressed: _submitReply,
                child: const Text('Reply to Post'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
