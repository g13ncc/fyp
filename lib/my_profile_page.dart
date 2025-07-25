import 'package:flutter/material.dart';
import 'account_setting_page.dart';
import 'all_posts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  int _postsCount = 0;
  int _likesCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchCounts();
  }

  Future<void> _fetchCounts() async {
    final user = FirebaseService.getCurrentUser();
    if (user == null) return;
    // Count posts
    final postsSnap = await FirebaseFirestore.instance.collection('posts').where('uid', isEqualTo: user.uid).get();
    // Count likes
    final likesSnap = await FirebaseFirestore.instance.collection('posts').where('likes', arrayContains: user.uid).get();
    setState(() {
      _postsCount = postsSnap.docs.length;
      _likesCount = likesSnap.docs.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseService.getCurrentUser();
    if (currentUser == null || currentUser.uid == null) {
      return Scaffold(
        body: Center(child: Text('User not logged in. Please log in again.', style: TextStyle(color: Colors.red))),
      );
    }
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('My Profile', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              // Profile Card (real user info)
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('users').doc(currentUser.uid).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                  return Container(
                    width: double.infinity,
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
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Profile Avatar
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: userData['profileImageBase64'] != null && userData['profileImageBase64'] != ''
                                ? ClipOval(
                                    child: Image.memory(
                                      base64Decode(userData['profileImageBase64']),
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Icon(Icons.person, size: 40, color: Colors.grey[400]),
                                    ),
                                  )
                                : Icon(Icons.person, size: 40, color: Colors.grey[400]),
                          ),
                          SizedBox(height: 16),
                          // Full Name
                          Text(userData['displayName'] ?? 'Full Name', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),
                          SizedBox(height: 8),
                          // Bio
                          if ((userData['bio'] ?? '').toString().isNotEmpty)
                            Text(userData['bio'], style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                          SizedBox(height: 4),
                          // Activity
                          Text('Posts: $_postsCount | Likes: $_likesCount', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                          SizedBox(height: 20),
                          // Edit My Profile Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => AccountSettingPage()));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFB91C1C),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                              child: Text('EDIT MY PROFILE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              // User's Posts
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('posts').where('uid', isEqualTo: currentUser.uid).orderBy('createdAt', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    // Hide all errors, show nothing
                    return SizedBox.shrink();
                  }
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return Text('No posts yet.', style: TextStyle(color: Colors.grey[600]));
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final postRaw = doc.data();
                      final post = postRaw is Map<String, dynamic> ? Map<String, dynamic>.from(postRaw) : <String, dynamic>{};
                      // Defensive assignment for 'likes' and 'bookmarkedBy' fields
                      post['likes'] = (post['likes'] is List) ? post['likes'] : <String>[];
                      post['bookmarkedBy'] = (post['bookmarkedBy'] is List) ? post['bookmarkedBy'] : <String>[];
                      // Defensive assignment for other fields
                      post['authorName'] = post['authorName'] ?? 'Anonymous';
                      post['createdAt'] = post['createdAt'] ?? Timestamp.now();
                      post['commentsCount'] = post['commentsCount'] ?? 0;
                      post['content'] = post['content'] ?? '';
                      post['imageBase64'] = post['imageBase64'] ?? '';
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
                                    child: Text(post['authorName'][0].toUpperCase(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(post['authorName'], style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                        Text(post['createdAt'] is Timestamp ? DateFormat('MMM dd, yyyy at hh:mm a').format((post['createdAt'] as Timestamp).toDate()) : 'Just now', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              if (post['content'].isNotEmpty)
                                Text(post['content'], style: TextStyle(fontSize: 15, height: 1.4)),
                              if (post['imageBase64'].toString().isNotEmpty) ...[
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
                                        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                                        child: Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
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
                                  Text('${(post['likes'] as List).length}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                  SizedBox(width: 20),
                                  Icon(Icons.chat_bubble_outline, size: 20, color: Colors.grey[600]),
                                  SizedBox(width: 4),
                                  Text('${post['commentsCount']}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
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
              SizedBox(height: 20),
              // Rating Section (unchanged)
              Container(
                width: double.infinity,
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
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Rating', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
                          Spacer(),
                          Icon(Icons.more_horiz, color: Colors.grey[600], size: 20),
                        ],
                      ),
                      SizedBox(height: 20),
                      _buildRatingItem(Icons.star, 'Rating', context),
                      SizedBox(height: 12),
                      _buildRatingItem(Icons.leaderboard, 'League Rank', context),
                      SizedBox(height: 12),
                      _buildRatingItem(Icons.timeline, 'Activities', context),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AllPostsPage()));
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Color(0xFFB91C1C),
                            side: BorderSide(color: Color(0xFFB91C1C)),
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          child: Text('HOMEPAGE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildRatingItem(IconData icon, String title, BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
          Spacer(),
          Icon(
            Icons.chevron_right,
            size: 20,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }
}
