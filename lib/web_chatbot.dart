import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui;

class ChatbotWidget extends StatefulWidget {
  final String chatbotUrl;
  
  const ChatbotWidget({super.key, required this.chatbotUrl});

  @override
  _ChatbotWidgetState createState() => _ChatbotWidgetState();
}

class _ChatbotWidgetState extends State<ChatbotWidget> {
  late String viewId;
  
  @override
  void initState() {
    super.initState();
    viewId = 'chatbot-iframe-${DateTime.now().millisecondsSinceEpoch}';
    
    // Create iframe element
    final iframe = html.IFrameElement()
      ..src = widget.chatbotUrl
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..allow = 'microphone; camera; geolocation; display-capture';
    
    // Register the iframe with Flutter Web
    ui.platformViewRegistry.registerViewFactory(
      viewId,
      (int viewId) => iframe,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: HtmlElementView(
        viewType: viewId,
      ),
    );
  }
}
