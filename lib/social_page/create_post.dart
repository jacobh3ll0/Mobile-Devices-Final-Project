import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


//Handles the creation of a social post

class CreatePostPage extends StatefulWidget
{
  const CreatePostPage({super.key});

  @override
  CreatePostState createState() => CreatePostState();
}

class CreatePostState extends State<CreatePostPage>
{
  String currentUserDisplayName = "";
  String userProfileImageURL = "";
  String currentUserId = "";

  //Text field controllers
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageURLController = TextEditingController();

  @override
  void initState()
  {
    super.initState();
    fetchUserData(); //Fetch user data on page load
  }

  Future<void> fetchUserData() async //Function to load current user from database
  {
    try {
      User? user = FirebaseAuth.instance.currentUser; //Get current user

      if (user != null) //If the user exists
      {
        String uid = user.uid; //get the user id

        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get(); //Get the users information from the database

        if (userDoc.exists) //If the information exists
        {
          setState(()
          {

            currentUserDisplayName = userDoc.get('displayName') ?? "Unknown User"; //Get the display name (error = unknown user)
            userProfileImageURL = userDoc.get('profileImageURL') ?? ""; //Get PFP (error = No picture)
            currentUserId = uid;
          });
        }
      }
    }
    catch (e) //Handles inability to get user data (shouldnt happen)
    {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User data could not be loaded!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> isValidImageUrl(String url) async //Function to check if an image URL used for a post works
  {
    try
    {
      final response = await http.head(Uri.parse(url));

      if (response.statusCode == 200)
      {
        final contentType = response.headers['content-type'];

        if (contentType != null && contentType.startsWith('image/'))
        {
          return true;//Return true if valid image
        }
      }
      return false; //Return false if image is invalid
    }
    catch (e) //Handles error checking
    {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("There was an error validating the image!"),
          backgroundColor: Colors.red,
        ),
      );
      return false; //if error, invalid
    }
  }

  //Design of post creation page
  @override
  Widget build(BuildContext context) //Build of the actual input widget
  {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create a post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0), //Padding on all sides for Ascetics
        child: Column(
          children: <Widget>
          [
            //Image URL Field
            TextField(
              controller: _imageURLController,
              decoration: InputDecoration(
                labelText: 'Image URL (Optional)',
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey, //Gray border when not focused
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
            ),

            const SizedBox(height: 20),

            //Text of post
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Post Details',
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey, //Gray border when not focused
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
              maxLines: 5, //Allow up to 5 lines for input
            ),

            const SizedBox(height: 20),

            //Button to create the post
            ElevatedButton(
              child: Text('Create Post!'),
              onPressed: () async
              {
                //Set the values of the variables based on text entered into to controller text fields

                final userId = currentUserId;
                final userDisplayName = currentUserDisplayName;
                final userProfileImage = userProfileImageURL;
                final description = _descriptionController.text;
                final imageURL = _imageURLController.text;

                if (description.isNotEmpty) //Make the the required items have values
                {
                  if (imageURL.isNotEmpty && !(await isValidImageUrl(imageURL))) //Check if imageURL is valid
                  {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invalid image URL. Please check and try again.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return; //Stop here
                  }
                  else //Otherwise try to save to database
                  {
                    try
                    {
                      final postDoc = await FirebaseFirestore.instance //Save the provided information
                          .collection('socialPosts')
                          .add({
                        'userId': userId, //Include userID in post creation to allow deleting
                        'userDisplayName': userDisplayName,
                        'userProfileImageURL': userProfileImage,
                        'description': description,
                        'imageURL': imageURL,
                        'timeString': DateTime.now().toIso8601String(), //Save date as ISO format for more efficient sorting
                        'numComments': 0,
                        'numLikes': 0,
                        'likedBy': [], //Stores all users who like the post
                      });

                      //Return the post id back to the previous page
                      Navigator.pop(context, {
                        'postId': postDoc.id,
                      });
                    }
                    catch (e) //Handles the save to database failing
                    {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Unable to create the post ... Try again later!"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
                else //If invalid information was provided
                    {
                  showDialog(
                    context: context,
                    builder: (context)
                    {
                      return AlertDialog( //Present an error dialog to the user
                        title: Text('Invalid Post'),
                        content: Text('Some required fields missing!'),
                        actions: <Widget>[
                          TextButton( //Button for user to close window
                            child: Text('Close'),
                            onPressed: () {
                              Navigator.pop(context);  //Pop dialog box from naviagation stack
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}