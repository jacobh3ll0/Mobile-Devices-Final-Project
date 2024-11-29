import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

//This page defines the post widget

class PostWidget extends StatefulWidget //Class which defines required variables for widget
{
  final double baseTextSize = 15; //Sets the default text size for the entire app row. Everything scales off this.

  final String postId; //Unique post id
  final String userDisplayName; //user display name
  final String userProfileImageURL; //user profile picture url
  final String timeString; //Time of posting
  final String description; //Description text of post
  final String imageURL; //Image (optional) to include with post
  final int numComments; //Number of comments
  final int numLikes; //Number of likes
  final bool isLikedByCurrentUser; //Sets if the widget is liked by current user
  final bool isCurrentUserPost; //to identify if current user is owner of post (For delete ability)
  final Function(PostWidget) onDelete; //Allows widget to be deleted (Only if user is the one who post)
  final Function(BuildContext, PostWidget) onReply; //Handles replies to posts

  const PostWidget({ //PostWidget Constructor
    super.key,
    required this.postId,
    required this.userDisplayName,
    required this.userProfileImageURL,
    required this.timeString,
    required this.description,
    required this.imageURL,
    required this.numComments,
    required this.numLikes,
    required this.onDelete,
    required this.onReply,
    required this.isLikedByCurrentUser,
    required this. isCurrentUserPost,
  });

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> with AutomaticKeepAliveClientMixin //AutomaticKeepAliveClientMixin keeps all widgets active to prevent clearing
{
  bool _isLiked = false; //sets default state for if post is liked
  late int _likesCount;
  late int _commentCount;

  @override
  void initState() //Set initial states
  {
    super.initState();
    //Set values passed to widget creation
    _isLiked = widget.isLikedByCurrentUser;
    _likesCount = widget.numLikes;
    _commentCount = widget.numComments;
  }

  @override
  void didUpdateWidget(PostWidget oldWidget) //Detects change in a widget and will update comment count
  {
    super.didUpdateWidget(oldWidget);
    if (widget.numComments != oldWidget.numComments) //If comment count is different
    {
      setState(() {
        _commentCount = widget.numComments; //Update it
      });
    }
  }

  void _showDeleteConfirmation(BuildContext context) //Function to handle deleting for widget
  {
    showDialog(
      context: context,
      builder: (BuildContext context)
      {
        //Display alert box with prompt
        return AlertDialog(
          title: Text('Delete Post'),
          content: Text('Are you sure you want to delete your post?'),
          actions: [
            TextButton( //Delete button definition
              child: Text('Yes, delete my post'), //Delete button text
              onPressed: () {
                Navigator.of(context).pop();
                widget.onDelete(widget); //Call the widget delete Function passed with each widget definition
              },
            ),
            TextButton( //Cancel button
              child: Text('Cancel'), //Cancel button text
              onPressed: () {
                Navigator.of(context).pop(); //Remove alert of navigation stack
              },
            ),
          ],
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true; //Keep all widgets alive (To prevent stats from clearing on scroll)

  //Definition of widget design
  Widget build(BuildContext context) //Build the widget
  {

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
    child:  Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey, //Border color
          width: 1.0,         //Border thickness
        ),
        borderRadius: BorderRadius.circular(8.0), //Makes edges of border circular
      ),
    child:  Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1, //Allocate 1/7 of width for the PFP
          child: Padding(
            padding: const EdgeInsets.only(left: 3.0),
            child: Align(
              alignment: Alignment.topCenter, //Align the CircleAvatar to the top center
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey, //Background color for fallback
                child: widget.userProfileImageURL.isNotEmpty
                    ? ClipOval(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: Image.network(
                        widget.userProfileImageURL,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace)
                        {
                          //Fallback to default icon if the image fails to load
                          return const Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.black,
                          );
                        },
                      ),
                    ),
                  ),
                )
                    : const Icon( //Set default icon if no PFP
                  Icons.person,
                  size: 40,
                  color: Colors.black, // Fallback icon for no image
                ),
              ),
            ),
          ),
        ),

        //Right column of PostWidget
        Expanded(
          flex: 6, //Allocated 6/7 of space in row width.
          child: Padding(
            padding: const EdgeInsets.all(8.0), //Pad the items for aesthetics
            child: Column( //Define items in column
              crossAxisAlignment: CrossAxisAlignment.start, //Alignment
              children: [ //Has multiple rows within the row (Title, Body, Footer)

                //Start of Title Definition
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, //Align content to the start (left)
                        children: [
                          
                          //User display name
                          Text(
                            widget.userDisplayName,
                            style: TextStyle(
                              fontSize: widget.baseTextSize + 2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          
                          SizedBox(height: 4), //spacing between name and date
                          
                          //Date time string (24 hour)
                          Text(
                            widget.timeString,
                            style: TextStyle(
                              fontSize: widget.baseTextSize,
                              fontWeight: FontWeight.normal,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    //Hide post button
                    if (widget.isCurrentUserPost)
                      IconButton(
                        icon: Icon(
                          Icons.expand_more,
                          size: widget.baseTextSize,
                        ),
                        onPressed: () {
                          _showDeleteConfirmation(context); //Trigger delete confirmation
                        },
                      ),
                  ],
                ),
                //End of title definition

                const SizedBox(height: 8), //Box for spacing between title and body

                //Start of Body Definition
                
                //Post description text
                Text(
                  widget.description,
                  style: TextStyle(fontSize: widget.baseTextSize),
                ),

                const SizedBox(height: 12), //Space between text and image

                //Image definition
                if (widget.imageURL.isNotEmpty) //Ensure the image URL is not empty
                  SizedBox(
                    height: 200, //Set max height of image
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0), //Round the corners of the image
                      child: Image.network(
                        widget.imageURL,
                        fit: BoxFit.contain, //Ensure the image fits within constraints
                        errorBuilder: (context, error, stackTrace) {
                          return const Text(
                            'Image Failed to load, please try again later!', //Display error message if image fails to load
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12.0,
                            ),
                          );
                        },
                      ),
                    ),
                  )
                else // If no image is provided, display nothing
                  const Text(''), //Fallback if no image URL is provided

                //End of body definition

                const SizedBox(height: 8), //Box for spacing between image and footer

                //Start of footer definition
                Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween, //Create even spacing between all elements of footer
                  children:
                  [ //Define comment and like

                    //The comment button
                    Flexible(
                      child: Row(
                        children: [ //Children are the icon, and the scalable text depending on int size
                          IconButton(
                            icon: Icon(Icons.chat_bubble_outline, size: widget.baseTextSize), //The icon used
                              onPressed: () => widget.onReply(context, widget),
                          ),
                          Flexible( //Keep the text within the allocated container size (Used if numbers are large)
                            child: FittedBox(
                              fit: BoxFit.scaleDown, //Will scale down the size of text should the number be too large
                              child: Text(
                                '$_commentCount', //Display the number of comments
                                style: TextStyle(fontSize: widget.baseTextSize),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),



                    //The Like Button
                    Flexible(
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              _isLiked ? Icons.favorite : Icons.favorite_border, //Change icon based on _isLiked
                              color: _isLiked ? Colors.red : Colors.black,
                              size: widget.baseTextSize,
                            ),
                            onPressed: () async 
                            {
                              final user = FirebaseAuth.instance.currentUser; //Gets the current user
                              if (user == null) return; //Make sure the user is valid, otherwise stop here

                              final userId = user.uid; //Get current users id

                              setState(() 
                              {
                                _isLiked = !_isLiked; //Toggle like status
                                _likesCount += _isLiked ? 1 : -1; //Adjust like count
                              });

                              try 
                              {
                                final referencePost = FirebaseFirestore.instance.collection('socialPosts').doc(widget.postId); //Get post in reference from DB

                                if (_isLiked) //Check if liked
                                {
                                  //Set user to like post, increasing counter by 1
                                  await referencePost.update({
                                    'numLikes': FieldValue.increment(1), //Increment likes count by 1
                                    'likedBy': FieldValue.arrayUnion([userId]), //Add user to list of who liked post
                                  });
                                }
                                else //Otherwise the user already likes the post, so unlike
                                {
                                  await referencePost.update({
                                    'numLikes': FieldValue.increment(-1), //Decrement likes count by 1
                                    'likedBy': FieldValue.arrayRemove([userId]), //remove user from list of who likes post
                                  });
                                }
                              }
                              catch (e) //Catch an error updating likes
                              {
                                print("Failed to update likes: $e");

                                //revert like if firestore fails
                                setState(() {
                                  _isLiked = !_isLiked;
                                  _likesCount += _isLiked ? 1 : -1;
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Failed to like ... Try again later"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                          ),
                          Text(
                            '$_likesCount', //Display the current number of likes
                            style: TextStyle(
                              fontSize: widget.baseTextSize,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                //End of footer definition

              ],
            ),
          ),
        ),
      ],
    ),
    ),
    );
  }
}