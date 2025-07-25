import 'package:flutter/material.dart';
import 'points_system_modal.dart';

class SocialProfileModal extends StatefulWidget {
  const SocialProfileModal({super.key});

  @override
  _SocialProfileModalState createState() => _SocialProfileModalState();
}

class _SocialProfileModalState extends State<SocialProfileModal> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Social Profile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                    // Profile avatar placeholder
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.grey[400],
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Full Name
                    Text(
                      'Full Name',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Follow/Unfollow buttons removed
                    
                    SizedBox(height: 24),
                    
                    // Stats (followers/following) removed
                    
                    SizedBox(height: 24),
                    
                    // Menu items
                    _buildMenuItem(Icons.person, 'Points', () {
                      Navigator.of(context).pop(); // Close current modal
                      showDialog(
                        context: context,
                        builder: (context) => PointsSystemModal(),
                      );
                    }),
                    _buildMenuItem(Icons.bar_chart, 'Rankings', () {}),
                    _buildMenuItem(Icons.message, 'Message Full Name', () {}),
                    
                    SizedBox(height: 40), // Replace Spacer with fixed height
                    
                    // Action buttons
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFB91C1C),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: Text(
                              'BACK TO FEED',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 12),
                        
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Color(0xFFB91C1C),
                              side: BorderSide(color: Color(0xFFB91C1C)),
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: Text(
                              'BACK TO HOMEPAGE',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Container(
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
        ),
      ),
    );
  }
}
