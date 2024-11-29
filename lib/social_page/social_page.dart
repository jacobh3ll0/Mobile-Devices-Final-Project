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
        //Put all values into unsortedPosts List
        unsortedPosts = querySnapshot.docs.map((doc)
        {
          final data = doc.data();
          final likedBy = List<String>.from(data['likedBy'] ?? []); //fetch list of users that liked the post from the post data
          final isLiked = likedBy.contains(userId); //check if the current user liked the post

          //Get the post data and make a post widget
          return PostWidget(
            key: ValueKey(doc.id),
            postId: doc.id,
            userDisplayName: data['userDisplayName'] ?? 'Unknown User',
            userProfileImageURL: data['userProfileImageURL'] ?? '',
            description: data['description'] ?? '',
            imageURL: data['imageURL'] ?? '',
            timeString: DateFormat('M/d/yy - kk:mm').format(DateTime.parse(data['timeString'])),
            numComments: data['numComments'] ?? 0,
            numLikes: data['numLikes'] ?? 0,
            onHide: _hidePost,
            onReply: (context, post) => _navigateToRepliesPage(context, post),
            initialIsLiked: isLiked, // Pass initial like state
            onCommentAdded: () => _updateCommentCount(doc.id),
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

  void _updateCommentCount(String postId) //Function to update comment count on main screen when a new one is added
  {
    setState(() {
      for (var post in unsortedPosts) //Go through each post
      {
        if (post.postId == postId) //Until a post with the matching id is found
        {
          //Update the post with a new comment
          final updatedPost = PostWidget(
            key: ValueKey(post.postId),
            postId: post.postId,
            userDisplayName: post.userDisplayName,
            userProfileImageURL: post.userProfileImageURL,
            description: post.description,
            imageURL: post.imageURL,
            timeString: post.timeString,
            numComments: post.numComments + 1,
            numLikes: post.numLikes,
            onHide: _hidePost,
            onReply: post.onReply,
            initialIsLiked: post.initialIsLiked,
            onCommentAdded: post.onCommentAdded,
          );

          //Update the post in the current List
          unsortedPosts[unsortedPosts.indexOf(post)] = updatedPost;
          break;
        }
      }
    });
  }


  void _navigateToRepliesPage(BuildContext context, PostWidget post) //Function to navigate to post replies
  {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostRepliesPage(post: post), //Pass the selected post to the replies page
      ),
    );
      _loadPostsFromDB(); //Update the comment count
  }

  void _hidePost(PostWidget post) //Temporarily hides a post until refresh for now
  {
    setState(() {
      unsortedPosts.remove(post); //Simply removes it from the current list
    });
  }

  //Sorts posts by date for fluent display
  List<PostWidget> _sortPostsByDate()
  {
    unsortedPosts.sort((a, b) {
      final dateA = DateFormat('M/d/yy - kk:mm').parse(a.timeString);
      final dateB = DateFormat('M/d/yy - kk:mm').parse(b.timeString);
      return dateB.compareTo(dateA); // Descending order
    });
    return unsortedPosts;
  }

  //Design of page
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
                _loadPostsFromDB(); //Call reload of posts

                const SnackBar( //Output success
                  content: Text("Posts successfully reloaded!"),
                  backgroundColor: Colors.green,
                );
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
