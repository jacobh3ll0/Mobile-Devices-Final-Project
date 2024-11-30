import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'signup_preferences_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileCreationPage extends StatefulWidget
{
  final String uid; //Get the users ID from the account creation page

  ProfileCreationPage({super.key, required this.uid});

  @override
  _ProfileCreationPageState createState() => _ProfileCreationPageState();
}

//This class handles creating the profile data
class _ProfileCreationPageState extends State<ProfileCreationPage>
{

  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageURLController = TextEditingController();

  String _profileImageURL = ''; //Default storage for profile image =
  String? _gymExperience; //stores answer for gym experience (default unselected/null)
  String? _selectedGender; //stores answer for gender (default unselected/null)


  Future<bool> SaveProfileData(BuildContext context) async
  {
    try
    {
      String uid = widget.uid; //Get the passed user ID

      //Make sure that the DisplayName doesnt already exist in the system
      final existingUsers = await FirebaseFirestore.instance
          .collection('users')
          .where('displayName', isEqualTo: _displayNameController.text.trim())
          .get();

      if (existingUsers.docs.isNotEmpty) //If the user exists
      {
        ScaffoldMessenger.of(context).showSnackBar( //Dispaly error
          SnackBar(
            content: Text('Display name is already taken. Please choose another.'),
            backgroundColor: Colors.red,
          ),
        );
        return false; //prevent from going further
      }

      //Insert the user inputted information into the database
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': FirebaseAuth.instance.currentUser?.email, // Retrieve email from current user
        'displayName': _displayNameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'gender': _selectedGender,
        'gymExperience': _gymExperience,
        'profileImageURL': _profileImageURL,
      });


      //Move to the preferences page. and await until complete
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SignupProfilePreferencesPage()),
      );

      return true;
    }



    catch (e) //Catch an error inserting data. Should never happen since information validation
    {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save profile: $e"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }



  void _imageURLEntryDialog()
  {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Image URL'),
        content: TextField(
          controller: _imageURLController,
          decoration: InputDecoration(
            hintText: 'Image URL', //Show text in box
            border: OutlineInputBorder(), //Border box unfocused
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey, //Color unfocused
                width: 1.0,         //border width unfocused
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.blue, //color focused
                width: 2.0,         //border width focused
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog without changes
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: ()
            {
              setState(() //Update image URL string on submit
              {
                _profileImageURL = _imageURLController.text.trim();
              });
              Navigator.pop(context); // Close dialog
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create your profile'),
        automaticallyImplyLeading: false, //Prevent return arrow
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            //Profile picture layout
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200], //Grey background
                    child: ClipOval( //Put the image on it
                      child: _profileImageURL.isNotEmpty ? //If the url is not empty
                      Image.network(_profileImageURL,
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                        errorBuilder: (context, error, stackTrace)  //If there is an error getting the image, clear the controller, and image url
                        {
                          WidgetsBinding.instance.addPostFrameCallback((_)
                          {
                            setState(()
                            {
                              _profileImageURL = ''; //Clear URL
                              _imageURLController.clear(); //Clear the controller
                            });
                            ScaffoldMessenger.of(context).showSnackBar( //Output error
                              SnackBar(
                                content: Text('Image failed to load. Check your URL'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          });
                          return Icon(Icons.person, size: 50, color: Colors.grey); //Show the person icon after error
                        },
                      )
                          : Icon(Icons.person, size: 50, color: Colors.grey), //The default icon on the circle avatar
                    ),
                  ),

                  SizedBox(height: 10),

                  //Change PFP button definition
                  ElevatedButton(
                    onPressed: _imageURLEntryDialog,
                    child: Text('Insert a profile picture URL'),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30), //Spacing for aesthetics

            //Define input for displayName
            TextField(
              controller: _displayNameController,
              decoration: InputDecoration(
                labelText: 'Display Name',
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 2.0,
                  ),
                ),
              ),
            ),

            SizedBox(height: 20), //Spacing for aesthetics

            //Definition of the description
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 2.0,
                  ),
                ),
              ),
            ),

            SizedBox(height: 30), //Spacing for aesthetics

            //Title text for the gender radio box.
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Gender",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            SizedBox(height: 10), //Spacing for aesthetics

            //Definition for the actual radio boxes
            Row(
              children: [
                Row(
                  children: [
                    Radio<String>(
                      value: 'Male',
                      groupValue: _selectedGender, //Null val to start
                      onChanged: (value) {
                        setState(()
                        {
                          _selectedGender = value; //Update the valid on click
                        });
                      },
                    ),
                    Text('Male'),
                  ],
                ),

                SizedBox(width: 20), //Space them apart

                Row(
                  children: [
                    Radio<String>(
                      value: 'Female',
                      groupValue: _selectedGender, //start null
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                    ),
                    Text('Female'),
                  ],
                ),
              ],
            ),

            SizedBox(height: 30), //Spacing for aesthetics

            //Title text for the gym experience radio box
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Amount of Gym Experience",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            SizedBox(height: 10), //Spacing for aesthetics


            //Definees the actual radiobox for the experience levels
            Row(
              children: [
                Row(
                  children: [
                    Radio<String>(
                      value: 'Beginner',
                      groupValue: _gymExperience, //start null
                      onChanged: (value) {
                        setState(() {
                          _gymExperience = value; //Chance value on click
                        });
                      },
                    ),
                    Text('Beginner'),
                  ],
                ),

                SizedBox(width: 20), //Space them apart

                Row(
                  children: [
                    Radio<String>(
                      value: 'Intermediate',
                      groupValue: _gymExperience, //start null
                      onChanged: (value) {
                        setState(() {
                          _gymExperience = value;
                        });
                      },
                    ),
                    Text('Intermediate'),
                  ],
                ),

                SizedBox(width: 20), //Space them apart

                Row(
                  children: [
                    Radio<String>(
                      value: 'Expert',
                      groupValue: _gymExperience, //start null
                      onChanged: (value) {
                        setState(()
                        {
                          _gymExperience = value;
                        });
                      },
                    ),
                    Text('Expert'),
                  ],
                ),
              ],
            ),

            SizedBox(height: 30), //Spacing for aesthetics

            //Create Profile button definition
            Center(
              child: ElevatedButton(
                onPressed: () async
                {
                  //Make sure required values are filled
                if (_displayNameController.text.isNotEmpty && _gymExperience != null && _selectedGender != null)
                  {
                    bool profileCreationSuccess = await SaveProfileData(context); //Wait until the user data is saved to the database, and signup preferences is done

                    if(profileCreationSuccess)
                      {
                        Navigator.pop(context); //Return to signup page, to then return to login
                      }

                  }
                else //Otherwise output an error
                  {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('All fields must be filled!'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Text('Create Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }

}