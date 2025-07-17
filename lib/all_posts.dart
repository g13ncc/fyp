import 'package:flutter/material.dart';
import 'app_bottom_navigation.dart';
import 'new_post_modal.dart';
import 'edit_post_modal.dart';
import 'comments_modal.dart';
import 'social_profile_modal.dart';
import 'main.dart';

class AllPostsPage extends StatelessWidget {
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
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.chat_bubble_outline, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatbotPage()),
              );
            },
            tooltip: 'Chat with Agent',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
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
                    'All Posts',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Keep up with what\'s happening in our vibrant community.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // Content area
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  // Post card 1
                  Container(
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
                                  showDialog(
                                    context: context,
                                    builder: (context) => SocialProfileModal(),
                                  );
                                },
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.grey[300],
                                  child: Icon(Icons.person, color: Colors.grey[600]),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => SocialProfileModal(),
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Full Name',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        'Text',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => EditPostModal(),
                                  );
                                },
                                child: Icon(Icons.more_horiz, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 16),
                          
                          // Post content placeholder
                          Container(
                            width: double.infinity,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_outlined,
                                    size: 40,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: 8),
                                  Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.grey[400],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          SizedBox(height: 16),
                          
                          // Action buttons
                          Row(
                            children: [
                              Icon(Icons.favorite_border, size: 20, color: Colors.grey[600]),
                              SizedBox(width: 4),
                              Text('Count', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              SizedBox(width: 16),
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => CommentsModal(),
                                  );
                                },
                                child: Icon(Icons.chat_bubble_outline, size: 20, color: Colors.grey[600]),
                              ),
                              SizedBox(width: 4),
                              Text('Count', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              Spacer(),
                              Icon(Icons.bookmark_border, size: 20, color: Colors.grey[600]),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Post card 2
                  Container(
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
                                  showDialog(
                                    context: context,
                                    builder: (context) => SocialProfileModal(),
                                  );
                                },
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.grey[300],
                                  child: Icon(Icons.person, color: Colors.grey[600]),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => SocialProfileModal(),
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Another User',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        'Security Tip',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => EditPostModal(),
                                  );
                                },
                                child: Icon(Icons.more_horiz, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 16),
                          
                          // Post content placeholder
                          Container(
                            width: double.infinity,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.security,
                                    size: 40,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Security Content',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          SizedBox(height: 16),
                          
                          // Action buttons
                          Row(
                            children: [
                              Icon(Icons.favorite_border, size: 20, color: Colors.grey[600]),
                              SizedBox(width: 4),
                              Text('15', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              SizedBox(width: 16),
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => CommentsModal(),
                                  );
                                },
                                child: Icon(Icons.chat_bubble_outline, size: 20, color: Colors.grey[600]),
                              ),
                              SizedBox(width: 4),
                              Text('3', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              Spacer(),
                              Icon(Icons.bookmark_border, size: 20, color: Colors.grey[600]),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Post card 3
                  Container(
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
                                  showDialog(
                                    context: context,
                                    builder: (context) => SocialProfileModal(),
                                  );
                                },
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.grey[300],
                                  child: Icon(Icons.person, color: Colors.grey[600]),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => SocialProfileModal(),
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Gen Secure',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        'Official Account',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => EditPostModal(),
                                  );
                                },
                                child: Icon(Icons.more_horiz, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 16),
                          
                          // Post content placeholder
                          Container(
                            width: double.infinity,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.shield,
                                    size: 40,
                                    color: Color(0xFFB91C1C),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Welcome to GenSecure!',
                                    style: TextStyle(
                                      color: Color(0xFFB91C1C),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          SizedBox(height: 16),
                          
                          // Action buttons
                          Row(
                            children: [
                              Icon(Icons.favorite, size: 20, color: Color(0xFFB91C1C)),
                              SizedBox(width: 4),
                              Text('42', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              SizedBox(width: 16),
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => CommentsModal(),
                                  );
                                },
                                child: Icon(Icons.chat_bubble_outline, size: 20, color: Colors.grey[600]),
                              ),
                              SizedBox(width: 4),
                              Text('8', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              Spacer(),
                              Icon(Icons.bookmark, size: 20, color: Color(0xFFB91C1C)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // New post button
                  SizedBox(
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
                  
                  SizedBox(height: 20), // Bottom padding
                ],
              ),
            ),
          ],
        ),
      ),
      
      // Bottom navigation
      bottomNavigationBar: AppBottomNavigation(currentPage: 'home'),
    );
  }
}
