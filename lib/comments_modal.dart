import 'package:flutter/material.dart';
import 'firebase_service.dart';

class CommentsModal extends StatefulWidget {
  final String postId;

  const CommentsModal({super.key, required this.postId});

  @override
  _CommentsModalState createState() => _CommentsModalState();
}

class _CommentsModalState extends State<CommentsModal> {
  final TextEditingController _commentController = TextEditingController();
  bool _isPosting = false;

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      _isPosting = true;
    });

    try {
      await FirebaseService.addComment(widget.postId, _commentController.text.trim());
      _commentController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error posting comment: $e')),
      );
    } finally {
      setState(() {
        _isPosting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Consistent modal size for all pages
    final double modalWidth = MediaQuery.of(context).size.width > 600 ? 500 : MediaQuery.of(context).size.width * 0.9;
    final double modalHeight = MediaQuery.of(context).size.height > 800 ? 420 : MediaQuery.of(context).size.height * 0.8;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: modalWidth,
        height: modalHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Header (with only one close icon, no title)
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
            // Comments section
            Container(
              padding: EdgeInsets.all(16),
              alignment: Alignment.centerLeft,
              child: Text(
                'Comments',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            
            // Comments list
            Expanded(
              child: StreamBuilder(
                stream: FirebaseService.getComments(widget.postId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                  final comments = snapshot.data!.docs;
                  if (comments.isEmpty) {
                    return Center(child: Text('No comments yet.'));
                  }
                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final data = comments[index].data() as Map<String, dynamic>;
                      return _buildCommentItem(
                        data['authorName'] ?? 'Anonymous',
                        data['comment'] ?? '',
                        isFirst: index == 0,
                      );
                    },
                  );
                },
              ),
            ),
            
            // Comment input section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Enter Comment',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isPosting ? null : _addComment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFB91C1C),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: _isPosting ? CircularProgressIndicator() : Text('POST', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCommentItem(String username, String comment, {bool isFirst = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0), // Align with 'Comments' title
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar with padding
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isFirst ? Color(0xFFB91C1C) : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: isFirst ? Colors.white : Colors.grey[600],
                size: 18,
              ),
            ),
          ),
          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$username :',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '$comment',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
