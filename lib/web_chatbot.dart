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
  @override
  void initState() {
    super.initState();
    // Register the iframe view for web
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    ui_web.platformViewRegistry.registerViewFactory(
      'chatbot-iframe',
      (int viewId) {
        final iframe = html.IFrameElement()
          ..src = '${widget.chatbotUrl}&t=$timestamp'
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%';
        return iframe;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const HtmlElementView(viewType: 'chatbot-iframe');
  }
}
