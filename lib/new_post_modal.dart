import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'firebase_service.dart';

class NewPostModal extends StatefulWidget {
  final String? postId;
  final String? initialContent;
  final String? initialImageBase64;
  const NewPostModal({Key? key, this.postId, this.initialContent, this.initialImageBase64}) : super(key: key);

  @override
  _NewPostModalState createState() => _NewPostModalState();
}

class _NewPostModalState extends State<NewPostModal> {
  late TextEditingController _textController;
  File? _selectedImage;
  Uint8List? _webImageBytes;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool get isEditMode => widget.postId != null;
  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialContent ?? '');
    if (widget.initialImageBase64 != null && widget.initialImageBase64!.isNotEmpty) {
      try {
        _webImageBytes = base64Decode(widget.initialImageBase64!);
      } catch (_) {}
    }
  }

  Future<void> _createPost() async {
    String? imageBase64;
    if (kIsWeb && _webImageBytes != null) {
      imageBase64 = base64Encode(_webImageBytes!);
    } else if (_selectedImage != null) {
      final bytes = await _selectedImage!.readAsBytes();
      imageBase64 = base64Encode(bytes);
    } else if (widget.initialImageBase64 != null && widget.initialImageBase64!.isNotEmpty) {
      imageBase64 = widget.initialImageBase64;
    }

    if (_textController.text.trim().isEmpty && imageBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add some content or an image')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    bool shouldClose = false;
    try {
      if (isEditMode) {
        // Update existing post using FirebaseService
        await FirebaseService.updatePost(
          postId: widget.postId!,
          content: _textController.text.trim(),
          imageBase64: imageBase64 ?? '',
        );
        shouldClose = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post updated successfully!')),
        );
      } else {
        // Create new post
        final postId = await FirebaseService.createPostBase64(
          content: _textController.text.trim(),
          imageBase64: imageBase64,
        );
        if (postId != null) {
          shouldClose = true;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Post created successfully!')),
          );
        } else {
          shouldClose = true;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: Post not created.')),
          );
        }
      }
    } catch (e) {
      shouldClose = true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      if (shouldClose) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          setState(() {
            _webImageBytes = bytes;
          });
        } else {
          setState(() {
            _selectedImage = File(image.path);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditMode ? 'Edit Post' : 'Create New Post',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(Icons.close, color: Colors.grey[600], size: 20),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditMode ? 'Edit your post:' : 'What\'s on your mind?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12),
                    // Text input
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        maxLines: null,
                        expands: true,
                        decoration: InputDecoration(
                          hintText: isEditMode ? 'Edit your post...' : 'Share your thoughts...',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Color(0xFFB91C1C)),
                          ),
                          contentPadding: EdgeInsets.all(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Image preview
                    if ((kIsWeb && _webImageBytes != null) || (!kIsWeb && _selectedImage != null)) ...[
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: kIsWeb
                                  ? Image.memory(
                                      _webImageBytes!,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      _selectedImage!,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (kIsWeb) {
                                      _webImageBytes = null;
                                    } else {
                                      _selectedImage = null;
                                    }
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                    // Action buttons
                    Row(
                      children: [
                        // Add image button
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickImage,
                            icon: Icon(Icons.image, color: Colors.grey[600]),
                            label: Text(
                              'Add Image',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey[300]!),
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        // Post button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _createPost,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFB91C1C),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(isEditMode ? 'Update' : 'Post'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
