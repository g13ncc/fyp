// Web-specific implementation
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

class ChatbotWidget extends StatefulWidget {
  final String chatbotUrl;
  
  const ChatbotWidget({super.key, required this.chatbotUrl});

  @override
  State<ChatbotWidget> createState() => _ChatbotWidgetState();
}

class _ChatbotWidgetState extends State<ChatbotWidget> {
  String? _viewType;

  @override
  void initState() {
    super.initState();
    // Create unique view type for each instance
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _viewType = 'chatbot-iframe-$timestamp';
    
    // Register the iframe view for web
    ui_web.platformViewRegistry.registerViewFactory(
      _viewType!,
      (int viewId) {
        final iframe = html.IFrameElement()
          ..src = '${widget.chatbotUrl}&t=$timestamp'
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allowFullscreen = true;
        return iframe;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _viewType != null 
        ? HtmlElementView(viewType: _viewType!)
        : const Center(child: CircularProgressIndicator());
  }
}
