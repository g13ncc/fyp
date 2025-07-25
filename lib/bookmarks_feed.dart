import 'package:flutter/material.dart';
import 'app_bottom_navigation.dart';
import 'new_post_modal.dart';
import 'comments_modal.dart';
import 'comments_modal.dart';
import 'comments_modal.dart';
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
      body: StreamBuilder<QuerySnapshot>(
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
            return Center(child: Text('No bookmarked posts yet.'));
          }
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final post = doc.data() as Map<String, dynamic>;
              // Defensive assignment for 'likes' and 'bookmarkedBy' fields
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
                                  DateFormat('MMM dd, yyyy • hh:mm a').format(
                                    post['createdAt'] is Timestamp
                                        ? post['createdAt'].toDate()
                                        : DateTime.tryParse(post['createdAt'].toString()) ?? DateTime.now(),
                                  ),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // ... (rest of the post actions)
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(post['content'] ?? ''),
                      if (post['imageBase64'] != null && post['imageBase64'].isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              base64Decode(post['imageBase64']),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 40, color: Colors.grey[400]),
                            ),
                          ),
                        ),
                      // ... (rest of the post content)
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: AppBottomNavigation(currentPage: 'bookmarks'),
    );
  }
}
