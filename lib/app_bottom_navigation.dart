import 'package:flutter/material.dart';
import 'all_posts.dart';
import 'following_feed.dart';
import 'likes_feed.dart';
import 'bookmarks_feed.dart';
import 'my_profile_page.dart';

class AppBottomNavigation extends StatelessWidget {
  final String currentPage;

  const AppBottomNavigation({Key? key, required this.currentPage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                Icons.home,
                'Home',
                currentPage == 'home',
                () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AllPostsPage()),
                ),
              ),
              _buildNavItem(
                context,
                Icons.people_outline,
                'Following',
                currentPage == 'following',
                () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => FollowingFeedPage()),
                ),
              ),
              _buildNavItem(
                context,
                Icons.favorite_border,
                'Likes',
                currentPage == 'likes',
                () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LikesFeedPage()),
                ),
              ),
              _buildNavItem(
                context,
                Icons.bookmark_border,
                'Bookmarks',
                currentPage == 'bookmarks',
                () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => BookmarksFeedPage()),
                ),
              ),
              _buildNavItem(
                context,
                Icons.person_outline,
                'Profile',
                currentPage == 'profile',
                () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MyProfilePage()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Color(0xFFB91C1C) : Colors.grey[600],
            size: 24,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Color(0xFFB91C1C) : Colors.grey[600],
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
