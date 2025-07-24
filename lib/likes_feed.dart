import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'firebase_service.dart';
import 'app_bottom_navigation.dart';
import 'new_post_modal.dart';

class LikesFeedPage extends StatelessWidget {
  const LikesFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseService.getCurrentUser();
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Likes Feed',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseService.getLikedPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No liked posts yet.'));
          }
          return ListView.builder(
            padding: EdgeInsets.all(16),
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
                      Row(
                        children: [
                          CircleAvatar(
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
                        ],
                      ),
                      SizedBox(height: 12),
                      if (post['content'] != null && post['content'].isNotEmpty)
                        Text(
                          post['content'],
                          style: TextStyle(fontSize: 15, height: 1.4),
                        ),
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
                      Row(
                        children: [
                          Icon(Icons.favorite, size: 20, color: Colors.red),
                          SizedBox(width: 4),
                          Text(
                            '${post['likes'] != null ? (post['likes'] as List).length : 0}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                          SizedBox(width: 20),
                          Icon(Icons.chat_bubble_outline, size: 20, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Text(
                            '${post['commentsCount'] ?? 0}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                          SizedBox(width: 20),
                          Icon(Icons.bookmark_border, size: 20, color: Colors.grey[600]),
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
      bottomNavigationBar: AppBottomNavigation(currentPage: 'likes'),
    );
  }
}
