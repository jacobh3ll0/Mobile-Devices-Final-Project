import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'post_reply.dart';
import 'post_widget.dart';

//This page handles the replies of a comment

class PostRepliesPage extends StatefulWidget
{
  final PostWidget post;

  const PostRepliesPage(
      {
        super.key,
        required this.post,
      });

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
    setState(()
    {
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

  void _navigateToReplyPage(BuildContext context) async {
    final replyAdded = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReplyPage(
          postId: widget.post.postId,
          originalPostDescription: widget.post.description,
        ),
      ),
    );

    if (replyAdded == true)
    {
      await _loadReplies(); //Reload the replies
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
          //THIS IS NOT IDEAL, but it is functional for now. Legit just rebuilt the widget for the replies page without the footer.
          //Show the post that the comments belong to at the top
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey, //Border color
                    width: 1.0,         //Border thickness
                  ),
                  borderRadius: BorderRadius.circular(8.0), //Rounded corners
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Left column for Profile Picture
                    Expanded(
                      flex: 1, //Allocate 1/7 of width
                      child: Padding(
                        padding: const EdgeInsets.only(left: 3.0),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey, //Fallback color
                            child: widget.post.userProfileImageURL.isNotEmpty
                                ? ClipOval(
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: Image.network(
                                    widget.post.userProfileImageURL,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
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
                                : const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.black, //Fallback icon
                            ),
                          ),
                        ),
                      ),
                    ),

                    //Right column for Post Content
                    Expanded(
                      flex: 6, //Allocate 6/7 of space
                      child: Padding(
                        padding: const EdgeInsets.all(8.0), //Padding for aesthetics
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //Title Section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      //User Display Name
                                      Text(
                                        widget.post.userDisplayName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 4), //Spacing between name and date

                                      //Date and Time
                                      Text(
                                        widget.post.timeString,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8), //Spacing between title and body

                            // Description
                            Text(
                              widget.post.description,
                              style: const TextStyle(fontSize: 14),
                            ),

                            const SizedBox(height: 12), //Space between text and image

                            // Image (if any)
                            if (widget.post.imageURL.isNotEmpty)
                              SizedBox(
                                height: 200,
                                child: Image.network(
                                  widget.post.imageURL,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Text(
                                      'Image Failed to load, please try again later!',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12.0,
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),


          //This just passes the whole widget, out for now as I was having issues getting comments to update count
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: IgnorePointer(
          //     child: widget.post, // Prevent any interaction with this widget
          //   ),
          // ),

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
                    ), // Convert ISO to human readable format
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