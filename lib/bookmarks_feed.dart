import 'package:flutter/material.dart';
import 'app_bottom_navigation.dart';
import 'new_post_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'firebase_service.dart';
import 'dart:convert';


class BookmarksFeedPage extends StatelessWidget {
  const BookmarksFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Bookmarks Feed',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // Header section
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFFB91C1C),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'HOMEPAGE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Bookmarks',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Bookmark posts from other users to see them here.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Content area
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .where('bookmarkedBy', arrayContains: FirebaseService.getCurrentUser()?.uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: \n${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bookmark_border, size: 64, color: Colors.grey[400]),
                        SizedBox(height: 16),
                        Text('No bookmarked posts', style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                        SizedBox(height: 8),
                        Text('Bookmark posts to see them here!', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.all(20),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final post = doc.data() as Map<String, dynamic>;
                    // Ensure 'likes' and 'bookmarkedBy' fields are always lists
                    if (post['likes'] == null || post['likes'] is! List) {
                      post['likes'] = <String>[];
                    }
                    if (post['bookmarkedBy'] == null || post['bookmarkedBy'] is! List) {
                      post['bookmarkedBy'] = <String>[];
                    }
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
                                  child: CircleAvatar(
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
                                            ? DateFormat('MMM dd, yyyy at hh:mm a').format((post['createdAt'] as Timestamp).toDate())
                                            : 'Just now',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.more_horiz, color: Colors.grey[600]),
                              ],
                            ),
                            SizedBox(height: 12),
                            // Post content
                            if (post['content'] != null && post['content'].isNotEmpty)
                              Text(
                                post['content'],
                                style: TextStyle(fontSize: 15, height: 1.4),
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
                                  stream: FirebaseFirestore.instance.collection('posts').doc(doc.id).snapshots(),
                                  builder: (context, snap) {
                                    if (!snap.hasData) {
                                      return Icon(Icons.favorite_border, size: 20, color: Colors.grey[600]);
                                    }
                                    final postData = snap.data!.data() as Map<String, dynamic>?;
                                    final likes = postData?['likes'] as List<dynamic>? ?? [];
                                    final currentUser = FirebaseService.getCurrentUser();
                                    final isLiked = currentUser != null && likes.contains(currentUser.uid);
                                    return GestureDetector(
                                      onTap: () {
                                        if (currentUser != null) {
                                          FirebaseService.toggleLike(doc.id);
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
                                          Text('${likes.length}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(width: 20),
                                // Comment button
                                GestureDetector(
                                  onTap: () {
                                    // Show comments modal (implement if needed)
                                  },
                                  child: Row(
                                    children: [
                                      Icon(Icons.chat_bubble_outline, size: 20, color: Colors.grey[600]),
                                      SizedBox(width: 4),
                                      StreamBuilder<QuerySnapshot>(
                                        stream: FirebaseFirestore.instance.collection('posts').doc(doc.id).collection('comments').snapshots(),
                                        builder: (context, snap) {
                                          final commentCount = snap.hasData ? snap.data!.docs.length : 0;
                                          return Text('$commentCount', style: TextStyle(color: Colors.grey[600], fontSize: 12));
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 20),
                                // Bookmark button (active)
                                Icon(Icons.bookmark, size: 20, color: Color(0xFFB91C1C)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // ...existing code...
        ],
      ),
      
      // Bottom navigation
      bottomNavigationBar: AppBottomNavigation(currentPage: 'bookmarks'),
    );
  }
}
