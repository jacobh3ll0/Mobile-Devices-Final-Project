import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'post_replies.dart';
import 'post_widget.dart';
import 'create_post.dart';
import 'package:intl/intl.dart';

//This is the main social page containing posts

class SocialPage extends StatefulWidget
{
  const SocialPage({super.key});

  @override
  _SocialState createState() => _SocialState();
}

class _SocialState extends State<SocialPage>
{
  List<PostWidget> unsortedPosts = []; //List for posts


  @override
  void initState()
  {
    super.initState();
    _loadPostsFromDB(); //Load the posts from database when page loaded
  }

  Future<void> _loadPostsFromDB() async //Function to get all posts
  {
    try
    {
      final user = FirebaseAuth.instance.currentUser; //Get current user to check if they have liked a comment
      if (user == null) return; //If the user cant be found, return

      final userId = user.uid; //Get the user id

      final querySnapshot = await FirebaseFirestore.instance.collection('socialPosts').get(); //Get values from table "socialPosts"
      setState(()
      {
        //put all posts in unsorted
        unsortedPosts = querySnapshot.docs.map((doc)
        {
          final data = doc.data();
          final likedBy = List<String>.from(data['likedBy'] ?? []);
          final isLiked = likedBy.contains(userId); //Check if the post is liked by the current user
          final isUserPost = data['userId'] == userId; //Check if the post belongs to the current user

          return PostWidget(
            key: ValueKey(doc.id), //Unique Key
            postId: doc.id, //Unique post id
            userDisplayName: data['userDisplayName'] ?? 'Unknown User',
            userProfileImageURL: data['userProfileImageURL'] ?? '',
            description: data['description'] ?? '',
            imageURL: data['imageURL'] ?? '',
            timeString: DateFormat('M/d/yy - kk:mm').format(DateTime.parse(data['timeString'])),
            numComments: data['numComments'] ?? 0,
            numLikes: data['numLikes'] ?? 0,
            onDelete: _deletePost, //Handles deleting a post
            onReply: (context, post) => _navigateToRepliesPage(context, post),
            isLikedByCurrentUser: isLiked,
            isCurrentUserPost: isUserPost,
          );
        }).toList();
      });
    }
    catch (e) //Error if load fails
    {
      const SnackBar(
        content: Text("Failed to load social posts!"),
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _navigateToRepliesPage(BuildContext context, PostWidget post) //Function to navigate to post replies
   async {
     await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostRepliesPage(post: post), //Pass the selected post to the replies page
      ),
    );

    setState(() {
      _loadPostsFromDB(); //Update the comment count
    });

  }

  Future<void> _deletePost(PostWidget post) async //Function to delete a post and all comments
  {
    try
    {
      //Delete post
      await FirebaseFirestore.instance.collection('socialPosts').doc(post.postId).delete();

      //Get all comments for a post
      final querySnapshot = await FirebaseFirestore.instance.collection('socialReplies').where('postId', isEqualTo: post.postId).get();

      //Go through each comment and delete
      for (var doc in querySnapshot.docs)
      {
        await doc.reference.delete();
      }

      //Show successful delete
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your post has been successfully deleted!'),
          backgroundColor: Colors.green,
        ),
      );
    }
    catch (e) //Catch failed delete
    {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your post could not be deleted at this time. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(()
    {
       unsortedPosts = []; //Clear users displayed posts
    });
    _loadPostsFromDB(); //Reload them all (Effectively removing the deleted post for users view)
  }

  //Sorts posts by date for fluent display
  List<PostWidget> _sortPostsByDate()
  {
    unsortedPosts.sort((a, b)
    {
      final dateA = DateFormat('M/d/yy - kk:mm').parse(a.timeString);
      final dateB = DateFormat('M/d/yy - kk:mm').parse(b.timeString);
      return dateB.compareTo(dateA); //Descending order
    });
    return unsortedPosts;
  }

  //Design of social page
  @override
  Widget build(BuildContext context) {

    List<PostWidget> sortedPosts = _sortPostsByDate(); //Sort the posts

    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Page'),
        actions: [

          //Button to add a post
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async
            {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreatePostPage()),
              );

              if (result != null && result is Map)
              {
                setState(()
                {
                  _loadPostsFromDB();
                });
              }
            },
          ),


          //Button to refresh posts (Will add scroll down to refresh later)
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async
            {
              try
              {
                setState(() {
                  unsortedPosts = []; //Clears all posts
                });
                _loadPostsFromDB(); //Reloads all the posts
              }
              catch (e)
              {
                const SnackBar(
                  content: Text("Failed to refresh posts ..."),
                  backgroundColor: Colors.red,
                );
              }
            },
          ),
        ],
      ),
      body: sortedPosts.isEmpty //If there is nothing in the sortedPosts Lists, output text by default
          ? const Center(
        child: Text(
          'Nothing posted yet!',
          style: TextStyle(fontSize: 14, color: Colors.black),
        ),
      )
          : ListView( //Otherwise output all widgets
        padding: const EdgeInsets.all(8.0),
        children: sortedPosts, // Display all posts (sorted)
      ),
    );
  }
}
