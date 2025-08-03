import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _registerChatbotView();
    }
  }

  void _registerChatbotView() {
    // Register the HTML view for web platform
    ui_web.platformViewRegistry.registerViewFactory(
      'chatbot-html',
      (int viewId) {
        final iframe = html.IFrameElement();
        iframe.src = 'assets/assets/chatbot.html';
        iframe.style.border = 'none';
        iframe.style.width = '100%';
        iframe.style.height = '100%';
        
        // Handle iframe load
        iframe.onLoad.listen((event) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        });
        
        return iframe;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Icon(Icons.chat_bubble_outline, color: Color(0xFFB91C1C), size: 24),
            SizedBox(width: 8),
            Text(
              'Gensecure AI Chatbot',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: kIsWeb
          ? Stack(
              children: [
                // Web view for chatbot
                HtmlElementView(viewType: 'chatbot-html'),
                
                // Loading indicator
                if (_isLoading)
                  Container(
                    color: Color(0xFFF5F5F5),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB91C1C)),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Loading Gensecure AI Chatbot...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            )
          : Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 24),
                    Text(
                      'AI Chatbot',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'AI Chatbot is only available on web platform.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please use the web version of this app to access the AI chatbot feature.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                    SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFB91C1C),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text('Go Back'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
