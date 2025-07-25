import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

class FirebaseService {
  // Delete user account and Firestore user document
  static Future<void> deleteCurrentUserAccount() async {
    try {
      User? user = currentUser;
      if (user == null) return;



      // Delete user document from Firestore
      await _firestore.collection(USERS_COLLECTION).doc(user.uid).delete();

      // Delete user from Firebase Auth
      await user.delete();
    } catch (e) {
      print('Error deleting user account: $e');
      rethrow;
    }
  }
  // Update an existing post
  static Future<void> updatePost({
    required String postId,
    required String content,
    String? imageBase64,
  }) async {
    await FirebaseFirestore.instance.collection(POSTS_COLLECTION).doc(postId).update({
      'content': content,
      'imageBase64': imageBase64 ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  // Update user profile (username, email, bio, profile image as base64)
  static Future<void> updateUserProfile({
    required String uid,
    String? displayName,
    String? email,
    String? username,
    String? phone,
    String? bio,
    String? profileImageBase64,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (displayName != null) data['displayName'] = displayName;
      if (email != null) data['email'] = email;
      if (username != null) data['username'] = username;
      if (phone != null) data['phone'] = phone;
      if (bio != null) data['bio'] = bio;
      if (profileImageBase64 != null) data['profileImageBase64'] = profileImageBase64;
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection(USERS_COLLECTION).doc(uid).update(data);
      // Optionally update Firebase Auth profile
      final user = _auth.currentUser;
      if (user != null) {
        if (displayName != null && displayName.isNotEmpty) await user.updateDisplayName(displayName);
        if (email != null && email.isNotEmpty && email != user.email) await user.updateEmail(email);
      }
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }
  // Create a new post with base64 image
  static Future<String?> createPostBase64({
    required String content,
    String? imageBase64,
    List<String>? tags,
  }) async {
    try {
      User? user = currentUser;
      if (user == null) return null;

      DocumentReference postRef = await _firestore.collection(POSTS_COLLECTION).add({
        'uid': user.uid,
        'authorName': user.displayName ?? 'Anonymous',
        'authorPhotoURL': user.photoURL ?? '',
        'content': content,
        'imageBase64': imageBase64 ?? '',
        'tags': tags ?? [],
        'likes': [],
        'bookmarkedBy': [],
        'likesCount': 0,
        'commentsCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection(USERS_COLLECTION).doc(user.uid).update({
        'postsCount': FieldValue.increment(1),
      });

      return postRef.id;
    } catch (e) {
      print('Error creating post (base64): $e');
      return null;
    }
  }
  // Upload image to Firebase Storage (Web)
  static Future<String?> uploadImageWeb(Uint8List bytes, String folder) async {
    try {
      User? user = currentUser;
      if (user == null) return null;

      String fileName = '${user.uid}_${DateTime.now().millisecondsSinceEpoch}';
      Reference ref = _storage.ref().child('$folder/$fileName');
      UploadTask uploadTask = ref.putData(bytes);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image (web): $e');
      return null;
    }
  }
  // Firebase instances
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collections
  static const String USERS_COLLECTION = 'users';
  static const String POSTS_COLLECTION = 'posts';
  static const String COMMENTS_COLLECTION = 'comments';

  // Auth methods
  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  static Future<UserCredential?> signUpWithEmail(String email, String password, String displayName) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name
      await result.user?.updateDisplayName(displayName);
      
      // Create user document in Firestore
      await createUserDocument(result.user!);
      
      return result;
    } catch (e) {
      print('Error signing up: $e');
      return null;
    }
  }

  // Get current user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Sign in with email and password
  static Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Create user document in Firestore
  static Future<void> createUserDocument(User user) async {
    try {
      await _firestore.collection(USERS_COLLECTION).doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName ?? 'Anonymous',
        'username': '',
        'bio': '',
        'phone': '',
        'profileImageBase64': '',
        'createdAt': FieldValue.serverTimestamp(),

        'postsCount': 0,
        'likesCount': 0,
      });
    } catch (e) {
      print('Error creating user document: $e');
    }
  }

  // Get user document
  static Future<DocumentSnapshot?> getUserDocument(String uid) async {
    try {
      return await _firestore.collection(USERS_COLLECTION).doc(uid).get();
    } catch (e) {
      print('Error getting user document: $e');
      return null;
    }
  }

  // Create a new post
  static Future<String?> createPost({
    required String content,
    String? imageUrl,
    List<String>? tags,
  }) async {
    try {
      User? user = currentUser;
      if (user == null) return null;

      DocumentReference postRef = await _firestore.collection(POSTS_COLLECTION).add({
        'uid': user.uid,
        'authorName': user.displayName ?? 'Anonymous',
        'authorPhotoURL': user.photoURL ?? '',
        'content': content,
        'imageUrl': imageUrl ?? '',
        'tags': tags ?? [],
        'likes': [],
        'likesCount': 0,
        'commentsCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update user's posts count
      await _firestore.collection(USERS_COLLECTION).doc(user.uid).update({
        'postsCount': FieldValue.increment(1),
      });

      return postRef.id;
    } catch (e) {
      print('Error creating post: $e');
      return null;
    }
  }

  // Get all posts (for All Posts page)
  static Stream<QuerySnapshot> getAllPosts() {
    return _firestore
        .collection(POSTS_COLLECTION)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }



  // Get user's liked posts
  static Stream<QuerySnapshot> getLikedPosts() {
    User? user = currentUser;
    if (user == null) return Stream.empty();

    return _firestore
        .collection(POSTS_COLLECTION)
        .where('likes', arrayContains: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Toggle like on a post
  static Future<void> toggleLike(String postId) async {
    try {
      User? user = currentUser;
      if (user == null) return;

      DocumentReference postRef = _firestore.collection(POSTS_COLLECTION).doc(postId);
      DocumentSnapshot postDoc = await postRef.get();
      
      if (!postDoc.exists) return;

      Map<String, dynamic> postData = postDoc.data() as Map<String, dynamic>? ?? {};
      List<String> likes = List<String>.from(postData['likes'] ?? []);
      
      if (likes.contains(user.uid)) {
        // Unlike
        await postRef.update({
          'likes': FieldValue.arrayRemove([user.uid]),
          'likesCount': FieldValue.increment(-1),
        });
      } else {
        // Like
        await postRef.update({
          'likes': FieldValue.arrayUnion([user.uid]),
          'likesCount': FieldValue.increment(1),
        });
      }
    } catch (e) {
      print('Error toggling like: $e');
    }
  }

  // Add comment to a post
  static Future<void> addComment(String postId, String comment) async {
    try {
      User? user = currentUser;
      if (user == null) return;

      await _firestore
          .collection(POSTS_COLLECTION)
          .doc(postId)
          .collection(COMMENTS_COLLECTION)
          .add({
        'uid': user.uid,
        'authorName': user.displayName ?? 'Anonymous',
        'authorPhotoURL': user.photoURL ?? '',
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update comments count
      await _firestore.collection(POSTS_COLLECTION).doc(postId).update({
        'commentsCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error adding comment: $e');
    }
  }

  // Get comments for a post
  static Stream<QuerySnapshot> getComments(String postId) {
    return _firestore
        .collection(POSTS_COLLECTION)
        .doc(postId)
        .collection(COMMENTS_COLLECTION)
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  // Upload image to Firebase Storage
  static Future<String?> uploadImage(String filePath, String folder) async {
    try {
      User? user = currentUser;
      if (user == null) return null;

      String fileName = '${user.uid}_${DateTime.now().millisecondsSinceEpoch}';
      Reference ref = _storage.ref().child('$folder/$fileName');
      
      List<int> fileBytes = await readFileAsBytes(filePath);
      UploadTask uploadTask = ref.putData(Uint8List.fromList(fileBytes));
      TaskSnapshot snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Helper method to read file as bytes (you'll need to implement based on your file handling)
  static Future<List<int>> readFileAsBytes(String filePath) async {
    // This is a placeholder - you'll implement this based on how you handle files
    // For now, return empty list
    return [];
  }


}
