import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'firebase_service.dart';
import 'all_posts.dart';
import 'auth_page.dart';

class AccountSettingPage extends StatefulWidget {
  const AccountSettingPage({super.key});

  @override
  _AccountSettingPageState createState() => _AccountSettingPageState();
}

class _AccountSettingPageState extends State<AccountSettingPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  // Removed username and phone controllers
  final TextEditingController _bioController = TextEditingController();

  String? _profileImageBase64;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseService.getCurrentUser();
    if (user == null) return;
    final doc = await FirebaseService.getUserDocument(user.uid);
    final data = doc?.data() as Map<String, dynamic>?;
    // Use Firestore if available, else fallback to Auth user info
    _fullNameController.text = (data?['displayName'] ?? user.displayName ?? '');
    _emailController.text = (data?['email'] ?? user.email ?? '');
    // Removed username and phone fields
    _bioController.text = (data?['bio'] ?? '');
    _profileImageBase64 = data?['profileImageBase64'] ?? '';
    setState(() { _loading = false; });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _profileImageBase64 = base64Encode(bytes);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Account Setting',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Account Settings Card
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
                            // Header
                      Text(
                        'Account Settings',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Profile Avatar
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: _profileImageBase64 != null && _profileImageBase64!.isNotEmpty
                                ? ClipOval(
                                    child: Image.memory(
                                      base64Decode(_profileImageBase64!),
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Icon(Icons.person, size: 40, color: Colors.grey[400]),
                                    ),
                                  )
                                : Icon(Icons.person, size: 40, color: Colors.grey[400]),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Center(child: Text('Tap to change profile picture', style: TextStyle(fontSize: 12, color: Colors.grey[500]))),
                      
                      SizedBox(height: 24),
                      
                      // Full Name Field
                      _buildFormField('Full Name', '', _fullNameController),
                      SizedBox(height: 16),
                      
                      // Email Field
                      _buildFormField('Email', '', _emailController),
                      SizedBox(height: 16),
                      
                      // Removed Username and Phone fields
                      
                      // Bio Field (single instance)
                      _buildFormField('Bio', '', _bioController),
                      SizedBox(height: 32),
                      
                      // Public Profile Field
                      // (Public Profile field removed)
                      
                      SizedBox(height: 24),
                      
                      // Removed duplicate Bio section
                      
                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final user = FirebaseService.getCurrentUser();
                            if (user == null) return;
                            // Always set/merge the user document with all fields
                            final data = {
                              'uid': user.uid,
                              'email': _emailController.text.trim(),
                              'displayName': _fullNameController.text.trim(),
                              'bio': _bioController.text.trim(),
                              'profileImageBase64': _profileImageBase64 ?? '',
                              'updatedAt': DateTime.now(),
                            };
                            await FirebaseFirestore.instance.collection('users').doc(user.uid).set(data, SetOptions(merge: true));
                            await FirebaseService.updateUserProfile(
                              uid: user.uid,
                              displayName: _fullNameController.text.trim(),
                              email: _emailController.text.trim(),
                              bio: _bioController.text.trim(),
                              profileImageBase64: _profileImageBase64,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Account updated successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
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
                            'SAVE',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 24),
                      
                      // Delete Account Button
                      Center(
                        child: TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Delete Account'),
                                content: Text('Are you sure you want to delete your account? This action cannot be undone.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) => Center(child: CircularProgressIndicator()),
                                      );
                                      try {
                                        await FirebaseService.deleteCurrentUserAccount();
                                        Navigator.of(context, rootNavigator: true).pop();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Account deleted successfully'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        // Navigate to login page (replace with your AuthPage route)
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(builder: (context) => AuthPage()),
                                          (route) => false,
                                        );
                                      } catch (e) {
                                        Navigator.of(context, rootNavigator: true).pop();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Failed to delete account: '
                                                '${e.toString().replaceAll('Exception:', '').trim()}'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Text(
                            'DELETE ACCOUNT',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 16),
                      
                      // Go Back to Homepage
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => AllPostsPage()),
                              (route) => false,
                            );
                          },
                          child: Text(
                            'GO BACK TO HOMEPAGE',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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
  
  Widget _buildFormField(String label, String initialValue, TextEditingController controller) {
    if (initialValue.isNotEmpty) {
      controller.text = initialValue;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText: initialValue.isEmpty ? 'Enter $label' : null,
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
  
  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    // Removed username and phone controllers
    _bioController.dispose();
    super.dispose();
  }
}
