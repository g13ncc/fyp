import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'comments_modal.dart';
import 'dart:convert';
import 'new_post_modal.dart';
import 'firebase_service.dart';
import 'main.dart';
import 'app_bottom_navigation.dart';
import 'comments_modal.dart';

class AllPostsPage extends StatefulWidget {
  const AllPostsPage({super.key});

  @override
  _AllPostsPageState createState() => _AllPostsPageState();
}

class _AllPostsPageState extends State<AllPostsPage> {
  // Helper to cache user profile images
  final Map<String, String?> _userProfileImageCache = {};

  Future<String?> _getUserProfileImage(String uid) async {
    if (_userProfileImageCache.containsKey(uid)) {
      return _userProfileImageCache[uid];
    }
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data();
    final img = (data != null && data['profileImageBase64'] != null && data['profileImageBase64'].toString().isNotEmpty)
        ? data['profileImageBase64'] as String
        : null;
    _userProfileImageCache[uid] = img;
    return img;
  }
  Future<void> _editPost(String postId, Map<String, dynamic> post) async {
    // Show NewPostModal in edit mode
    await showDialog(
      context: context,
      builder: (context) => NewPostModal(
        postId: postId,
        initialContent: post['content'] ?? '',
        initialImageBase64: post['imageBase64'] ?? '',
      ),
    );
  }

  Future<void> _deletePostAndComments(String postId) async {
    try {
      // Delete all comments subcollection
      final comments = await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .get();
      for (final doc in comments.docs) {
        await doc.reference.delete();
      }
      // Delete the post
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting post: $e')),
      );
    }
  }
  // Removed unused _deletePost method (use _deletePostAndComments only)

  Widget _buildPostCard(Map<String, dynamic> post, String postId, String? profileImageBase64) {
    final currentUser = FirebaseService.getCurrentUser();
    final isOwner = currentUser?.uid == post['uid'];
    // Defensive assignment for 'bookmarkedBy' field
    post['bookmarkedBy'] = (post['bookmarkedBy'] is List) ? post['bookmarkedBy'] : <String>[];
    return Container(
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User info
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Profile functionality would go here
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Profile feature coming soon!')),
                        );
                      },
                      child: (profileImageBase64 != null && profileImageBase64.isNotEmpty)
                          ? CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: MemoryImage(base64Decode(profileImageBase64)),
                            )
                          : CircleAvatar(
                              radius: 20,
                              backgroundColor: Color(0xFFB91C1C),
                              child: Text(
                                post['authorName']?[0]?.toUpperCase() ?? 'U',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['authorName'] ?? 'Anonymous',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        post['createdAt'] != null
                            ? DateFormat('MMM dd, yyyy • hh:mm a').format(
                                (post['createdAt'] as Timestamp).toDate())
                            : 'Just now',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isOwner) ...[
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editPost(postId, post);
                      } else if (value == 'delete') {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Delete Post'),
                            content: Text('Are you sure you want to delete this post?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _deletePostAndComments(postId);
                                },
                                child: Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            
            SizedBox(height: 12),
            
            // Post content
            if (post['content'] != null && post['content'].isNotEmpty)
              Text(
                post['content'],
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            
            // Post image (base64)
            if (post['imageBase64'] != null && post['imageBase64'].toString().isNotEmpty) ...[
              SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  base64Decode(post['imageBase64']),
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(Icons.image_not_supported, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            ],
            
            SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                // Like button
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .doc(postId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Icon(Icons.favorite_border, size: 20, color: Colors.grey[600]);
                    }
                    
                    final postData = snapshot.data!.data() as Map<String, dynamic>?;
                    final likes = postData?['likes'] as List<dynamic>? ?? [];
                    final isLiked = currentUser != null && likes.contains(currentUser.uid);
                    
                    return GestureDetector(
                      onTap: () {
                        if (currentUser != null) {
                          FirebaseService.toggleLike(postId);
                        }
                      },
                      child: Row(
                        children: [
                          Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 20,
                            color: isLiked ? Colors.red : Colors.grey[600],
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${likes.length}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                SizedBox(width: 20),
                
                // Comment button
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => CommentsModal(postId: postId),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 20, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('posts')
                            .doc(postId)
                            .collection('comments')
                            .snapshots(),
                        builder: (context, snapshot) {
                          final commentCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
                          return Text(
                            '$commentCount',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                SizedBox(width: 20),
                
                // Bookmark button
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection('posts').doc(postId).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Icon(Icons.bookmark_border, size: 20, color: Colors.grey[600]);
                    }
                    final postData = snapshot.data!.data() as Map<String, dynamic>?;
                    final bookmarkedBy = (postData?['bookmarkedBy'] as List<dynamic>?) ?? [];
                    final isBookmarked = currentUser != null && bookmarkedBy.contains(currentUser.uid);
                    return GestureDetector(
                      onTap: () {
                        if (currentUser != null) {
                          final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
                          if (isBookmarked) {
                            postRef.update({
                              'bookmarkedBy': FieldValue.arrayRemove([currentUser.uid]),
                            });
                          } else {
                            postRef.update({
                              'bookmarkedBy': FieldValue.arrayUnion([currentUser.uid]),
                            });
                          }
                        }
                      },
                      child: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        size: 20,
                        color: isBookmarked ? Color(0xFFB91C1C) : Colors.grey[600],
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'All Posts',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.chat_bubble_outline, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatbotPage()),
              );
            },
            tooltip: 'Chat with AI',
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              await FirebaseService.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MyApp()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Posts feed
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseService.getAllPosts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: \\${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.post_add, size: 64, color: Colors.grey[400]),
                        SizedBox(height: 16),
                        Text(
                          'No posts yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Be the first to share something!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final post = doc.data() as Map<String, dynamic>;
                    return FutureBuilder<String?>(
                      future: _getUserProfileImage(post['uid'] ?? ''),
                      builder: (context, snap) {
                        return _buildPostCard(post, doc.id, snap.data);
                      },
                    );
                  },
                );
              },
            ),
          ),
          // New post button
          Container(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => NewPostModal(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFB91C1C),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('NEW POST', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: AppBottomNavigation(currentPage: 'home'),
      // Floating action button removed as requested
    );
  }
}
