import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
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
        'photoURL': user.photoURL ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'followers': [],
        'following': [],
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

  // Get posts from followed users (for Following Feed)
  static Stream<QuerySnapshot> getFollowingPosts() {
    User? user = currentUser;
    if (user == null) return Stream.empty();

    return _firestore
        .collection(USERS_COLLECTION)
        .doc(user.uid)
        .snapshots()
        .asyncMap((userDoc) async {
      List<String> following = List<String>.from(userDoc.data()?['following'] ?? []);
      
      if (following.isEmpty) {
        return _firestore.collection(POSTS_COLLECTION).where('uid', isEqualTo: 'none').get();
      }

      return _firestore
          .collection(POSTS_COLLECTION)
          .where('uid', whereIn: following)
          .orderBy('createdAt', descending: true)
          .get();
    });
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

      List<String> likes = List<String>.from(postDoc.data() as Map<String, dynamic>?['likes'] ?? []);
      
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
      
      UploadTask uploadTask = ref.putData(await readFileAsBytes(filePath));
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

  // Follow/Unfollow user
  static Future<void> toggleFollow(String targetUserId) async {
    try {
      User? user = currentUser;
      if (user == null || user.uid == targetUserId) return;

      DocumentReference userRef = _firestore.collection(USERS_COLLECTION).doc(user.uid);
      DocumentReference targetRef = _firestore.collection(USERS_COLLECTION).doc(targetUserId);

      DocumentSnapshot userDoc = await userRef.get();
      List<String> following = List<String>.from(userDoc.data() as Map<String, dynamic>?['following'] ?? []);

      if (following.contains(targetUserId)) {
        // Unfollow
        await userRef.update({
          'following': FieldValue.arrayRemove([targetUserId]),
        });
        await targetRef.update({
          'followers': FieldValue.arrayRemove([user.uid]),
        });
      } else {
        // Follow
        await userRef.update({
          'following': FieldValue.arrayUnion([targetUserId]),
        });
        await targetRef.update({
          'followers': FieldValue.arrayUnion([user.uid]),
        });
      }
    } catch (e) {
      print('Error toggling follow: $e');
    }
  }
}
