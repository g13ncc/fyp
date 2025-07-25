import 'package:flutter/material.dart';
import 'app_bottom_navigation.dart';
import 'new_post_modal.dart';
import 'comments_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'firebase_service.dart';
import 'dart:convert';



class BookmarksFeedPage extends StatelessWidget {
  const BookmarksFeedPage({super.key});

  // Helper to fetch user profile image (base64) by uid
  Future<String?> _getUserProfileImage(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data();
    final img = (data != null && data['profileImageBase64'] != null && data['profileImageBase64'].toString().isNotEmpty)
        ? data['profileImageBase64'] as String
        : null;
    return img;
  }

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
              return FutureBuilder<String?>(
                future: _getUserProfileImage(post['uid'] ?? ''),
                builder: (context, snapshot) {
                  final profileImageBase64 = snapshot.data;
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
                              (profileImageBase64 != null && profileImageBase64.isNotEmpty)
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
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: AppBottomNavigation(currentPage: 'bookmarks'),
    );
  }
}
