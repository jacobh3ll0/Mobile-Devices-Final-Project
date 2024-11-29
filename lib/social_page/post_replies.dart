import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'post_reply.dart';
import 'post_widget.dart';

//This page handles the replies of a comment

class PostRepliesPage extends StatefulWidget
{
  final PostWidget post;
  const PostRepliesPage({super.key, required this.post});

  @override
  _PostRepliesPageState createState() => _PostRepliesPageState();
}

class _PostRepliesPageState extends State<PostRepliesPage>
{
  List<Map<String, dynamic>> replies = []; //Map of replies
  bool isLoading = true; //Here for loading if it takes a while (Aetheics)

  @override
  void initState()
  {
    super.initState();
    _loadReplies(); //Load the replies for the comment on load
  }

  Future<void> _loadReplies() async
  {
    setState(() {
      isLoading = true; //Set loading status to true (For circle loading)
    });

    try
    {
      //Get the post comments based on the post ID
      final querySnapshot = await FirebaseFirestore.instance.collection('socialReplies').where('postId', isEqualTo: widget.post.postId).get();

      setState(()
      {
        //Put values of replies into the replies map.
        replies = querySnapshot.docs.map((doc)
        {
          final data = doc.data();
          return {
            'userDisplayName': data['userDisplayName'] ?? 'Unknown User',
            'userProfileImageURL': data['userProfileImageURL'] ?? '',
            'description': data['description'] ?? '',
            'timeString': data['timeString'], // Keep as ISO for sorting
          };
        }).toList();

        //Sort the replies in descending order of date (newest first)
        replies.sort((a, b)
        {
          final timeA = DateTime.parse(a['timeString']);
          final timeB = DateTime.parse(b['timeString']);
          return timeB.compareTo(timeA); // Descending order
        });

        isLoading = false; //Indicate that loading completed
      });
    }
    catch (e)
    {
      setState(()
      {
        isLoading = false; //Complete the load on fail
      });
      //Display error to user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Replies failed to Load. Try again later!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToReplyPage(BuildContext context) async //Go to the reply page to make reply
  {
    final replyAdded = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReplyPage(
          postId: widget.post.postId,
          originalPostDescription: widget.post.description,
        ),
      ),
    );

    if (replyAdded == true) //Reload the replies once new one is added
    {
      await _loadReplies(); //Wait for all comments to load

      //Update comment count
      setState(() {
        widget.post.onCommentAdded(); // Notify the PostWidget to update its comment count
      });
    }
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        title: Text("Replies to ${widget.post.userDisplayName}'s Post"),
      ),
      body: isLoading //Boolean loaded status
          ? const Center(child: CircularProgressIndicator()) //Provides a circle loading when data not ready
          : Column(

        children: [

          //Show the post that the comments belong to at the top
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IgnorePointer(
              child: widget.post, // Prevent any interaction with this widget
            ),
          ),

          const Divider(),

          //List of all replies
          Expanded(
            child: replies.isEmpty
                ? const Center(child: Text("No replies yet.")) //Output if no replies
                : ListView.builder( //Otherwise build a list view below the post
              itemCount: replies.length,
              itemBuilder: (context, index) {
                final reply = replies[index];
                return ListTile(

                  //Display commenters PFP
                  leading: CircleAvatar(
                    radius: 25, //Size of PFP
                    backgroundColor: Colors.grey, //Fall back PFP color in case of invalid image
                    child: reply['userProfileImageURL'] != null && reply['userProfileImageURL'].isNotEmpty //Make sure image valid
                        ? ClipOval(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Image.network(
                            reply['userProfileImageURL'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace)
                            {
                              //If the image fails, set to default PFP
                              return const Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.black,
                              );
                            },
                          ),
                        ),
                      ),
                    )
                        : const Icon( //If no PFP, set to default
                      Icons.person,
                      size: 30,
                      color: Colors.black, // Fallback icon for no image
                    ),
                  ),
                  title: Text(reply['userDisplayName']),
                  subtitle: Text(reply['description']),
                  trailing: Text(
                    DateFormat('M/d/yy - kk:mm').format( //Sets the date format from ISO to standard date layout (I kept it iso cause ISO is faster for sorting
                      DateTime.parse(reply['timeString']),
                    ), // Convert ISO to readable format
                  ),
                );
              },
            ),
          ),
        ],
      ),

      //Button at bottom to add a reply
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToReplyPage(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}